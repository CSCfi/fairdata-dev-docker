#!/bin/bash
#########################################################
# This file is the startup file for the Frontend service,
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################
set -e
set -a && source /etc/environment && set +a

if [[ -f /first-time-init ]]; then

    echo "Fix PHP memory limit.."
    sed -i "s/128M/512M/g" /etc/opt/rh/rh-php71/php.ini
    echo "..fixed!"

    if [[ ! -f /nextcloud-installed ]]; then
        echo "Ensure that there is no old config"
        rm -f /var/ida/nextcloud/config/config.php
        echo "..ensured."
        echo "Ensure database.."
        set +e
        /opt/rh/rh-postgresql96/root/usr/bin/postgresql-setup --initdb
        chown -R postgres:postgres /var/opt/rh/rh-postgresql96/lib/pgsql/data
        set -e
        echo "..db ok."

        echo "Ensure permissions.."
        echo "local   all             postgres                                trust" > /var/opt/rh/rh-postgresql96/lib/pgsql/data/pg_hba.conf
        echo "local   all             nextcloud                                trust" >> /var/opt/rh/rh-postgresql96/lib/pgsql/data/pg_hba.conf
        echo "local   all             nextcloud                                trust" >> /var/opt/rh/rh-postgresql96/lib/pgsql/data/pg_hba.conf
        echo "host    all         all         127.0.0.1/32          trust" >> /var/opt/rh/rh-postgresql96/lib/pgsql/data/pg_hba.conf
        systemctl restart rh-postgresql96-postgresql
        echo "..permissions ok."

        echo "Ensure user accounts.."
        set +e
        psql -U postgres -c "create database nextcloud"
        psql -U postgres -c "create user nextcloud with password 'nextcloud'"
        psql -U postgres -c "grant all privileges on database nextcloud to nextcloud"
        set -e
        echo "..user accounts ok."

        echo "install nextcloud.."
        pushd /var/ida/nextcloud/
            sudo -u apache ./occ maintenance:install --database "pgsql" --database-name "nextcloud" --database-host "127.0.0.1" --database-user "nextcloud" --database-pass "nextcloud" --admin-user "admin" --admin-pass "test"  --data-dir "/mnt/storage_vol01/ida"
        popd
        echo "..nextcloud installed."
        touch /nextcloud-installed
    fi

    echo "Test that the service is up.."
    curl -L https://ida.csc.local --insecure > /dev/null
    echo "..it is."

    echo "modify config.php.."
    if [[ ! -f /code/config.php.bak ]]; then
        mv /var/ida/nextcloud/config/config.php /code/config.php.bak
    fi
    cp /code/config.php.template /code/config.php
    ln -s /code/config.php /var/ida/nextcloud/config/config.php
    INSTANCEID=$(cat /code/config.php.bak | grep -i instanceid | awk '{split($0,a,"=>"); print a[2]}' | sed "s/[\', ]//g" | sed "s/\+/\\\+/g" | sed "s/\//\\\\\//g")
    SECRET=$(cat /code/config.php.bak | grep -i secret | awk '{split($0,a,"=>"); print a[2]}' | sed "s/[\', ]//g" | sed "s/\+/\\\+/g" | sed "s/\//\\\\\//g")
    PASSWORD=$(cat /code/config.php.bak | grep -i passwordsalt | awk '{split($0,a,"=>"); print a[2]}' | sed "s/[\', ]//g" | sed "s/\+/\\\+/g" | sed "s/\//\\\\\//g")
    sed -i "s/REPLACE_PASSWORDSALT/${PASSWORD}/g" /code/config.php
    sed -i "s/REPLACE_SECRET/${SECRET}/g" /code/config.php
    sed -i "s/REPLACE_INSTANCEID/${INSTANCEID}/g" /code/config.php
    chown -R apache:apache /code
    echo "..config.php ok."

    echo "fix permissions.."
    /var/ida/utils/fix_permissions
    echo "..permissions ok."


    echo "App config.."
    pushd /var/ida/nextcloud/
        sudo -u apache ./occ app:enable ida
        sudo -u apache ./occ app:enable idafirstrunwizard
    popd
    echo "..app config done."

    echo "create indices.."
    pushd /var/ida/utils
        psql -U nextcloud -d nextcloud -f create_db_indices.ddl
    popd
    echo "..indices ok."

    set +e
    echo "link config.sh.."
    mkdir -p /code/ida/config
    ln -s /code/config.sh /code/ida/config/config.sh
    echo "..ok."

    echo "create projects to IDA.."
    sudo -u apache /var/ida/admin/ida_project ADD test_project 1
    sudo -u apache /var/ida/admin/ida_user ADD test_user test_project
    set -e
    echo "..projects created."

    echo "initialize rabbitmq.."
    source /srv/venv-agents/bin/activate && pip install -r /var/ida/agents/requirements.txt
    source /srv/venv-agents/bin/activate && pip install --upgrade pip
    pushd /var/ida/utils
        ./initialize_rabbitmq
    popd
    echo "..rabbitmq ok."

    echo "create test users and projects.."
    sudo -u apache /var/ida/tests/utils/initialize_test_accounts
    echo "..created."

    rm /first-time-init
fi

systemctl start rabbitmq-metadata-agent
systemctl start rabbitmq-replication-agent
