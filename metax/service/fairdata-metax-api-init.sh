#!/bin/bash
#########################################################
# This file is the startup file for the Backend service,
# it does contain also those initializations which
# are required for postgresql
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################
set -e
set -a; source /etc/environment; set +a
source /usr/local/metax/pyenv/bin/activate
export LANG=fi_FI.UTF8
export 

echo "Waiting for elasticsearch is available.."
# lets wait for awhile to ensure that elasticsearch is up
set +e
while true; do
    nc 127.0.0.1 9200 -z -w 59 2> /dev/null
    if [[ $? == 0 ]]; then
        break
    else
        sleep 1
    fi
done
set -e
echo "..elasticsearch has been started."

if [[ ! -d /usr/local/metax/refdata_indexer ]]; then

    echo "Installing local redis.."
    pushd /metax/ansible
        ansible-playbook provision_refdataservers.yml
    popd
    echo "..local redis installed."
    echo
    echo "Initializing metax things.."
    su - metax-user -c "
        set -e;
        set -a; source /etc/environment; set +a;
        pushd /code/metax-api/src &&
        source /usr/local/metax/pyenv/bin/activate &&
        python3 manage.py updatereferencedata &&
        python3 manage.py collectstatic --noinput &&
        python3 manage.py makemigrations metax_api &&
        python3 manage.py migrate metax_api &&
        python3 manage.py migrate &&
        popd"
    echo "..initialized."
    echo

    echo "Ensuring user permissions.."
    chown -R metax-user:metax /var/log/metax-api /code/metax-api/src /metax/ansible
    echo "..ensured."
    echo
    echo "Remove the first-time-init file.."
    rm -f /first-time-init
    echo "..removed."
    echo

    echo "Waiting for metax-api to start.."
    # lets wait for awhile to ensure that metax-api is up
    set +e
    while true; do
        nc 127.0.0.1 8000 -z -w 59 2> /dev/null
        if [[ $? == 0 ]]; then
            break
        else
            sleep 1
        fi
    done
    set -e
    echo "..metax has been started."
    echo
    echo "Importing initial data.."
    su - metax-user -c "
        set -e;
        set -a; source /etc/environment; set +a;
        pushd /code/metax-api/src &&
        source /usr/local/metax/pyenv/bin/activate &&
        python3 manage.py loaddata metax_api/tests/testdata/test_data.json &&
        python3 manage.py loadinitialdata &&
        popd"
    echo "..data imported."
fi
