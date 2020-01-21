#!/bin/bash
#########################################################
# This file is the startup file for the Etsin service,
# it does contain also those initializations
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################
set -e
set -a; source /etc/environment; set +a
export PATH=/code/node-v12.13.1-linux-x64/bin:${PATH}

echo
echo "Waiting until metax-api server is ready.."
set +e
while true; do
    nc ${APP_METAX_API_HOST} 443 -z -w 59 2> /dev/null
    if [[ $? == 0 ]]; then
        curl https://${APP_METAX_API_HOST}/rest/datasets --insecure -f -s > /dev/null
        if [[ $? == 0 ]]; then
            break
        else
            sleep 1
        fi
    fi
done
set -e
echo "..ok"
echo

echo "Provisioning.."
if [[ ! -f /usr/local/etsin/search_scripts/reindex_by_recreating_index.sh ]]; then
    pushd /code/etsin-ops/ansible
        ansible-galaxy install --roles-path=roles -r requirements.yml
        ansible-playbook -i inventories/local_development provision_dataservers.yml
        ansible-playbook -i inventories/local_development provision_webservers.yml
    popd
fi
echo "..ok"
echo

echo "Configuring.."
rm -f /first-time-init

systemctl enable memcached
systemctl enable nginx
systemctl enable rabbitmq-consumer

systemctl start memcached
systemctl start nginx
systemctl start rabbitmq-consumer

pushd /home/etsin-user
    test -f /root/advanced_settings.json || ln -s /home/etsin-user/advanced_settings.json /root/advanced_settings.json
    test -f /root/app_config || ln -s /home/etsin-user/app_config /root/app_config
    test -f /root/settings.json || ln -s /home/etsin-user/settings.json /root/settings.json
    chmod +r /home/etsin-user/advanced_settings.json /home/etsin-user/app_config /home/etsin-user/settings.json
popd
echo "..configure done."
echo

echo "Reindexing.."
su - etsin-user -c "/usr/local/etsin/search_scripts/reindex_by_recreating_index.sh"
echo "..reindex done."
echo

echo "Starting etsin_finder.."
pushd /code/etsin_finder
    /usr/local/etsin/pyenv/bin/gunicorn --bind unix:/usr/local/etsin/gunicorn/socket --access-logfile - --error-logfile - --config /etc/gunicorn.py --reload etsin_finder.finder:app
popd
echo "..done."
echo
exit 0