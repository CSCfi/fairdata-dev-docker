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

if [[ ! -f /usr/local/etsin/search_scripts/reindex_by_recreating_index.sh ]]; then
    pushd /code/etsin-ops/ansible
        ansible-galaxy install --roles-path=roles -r requirements.yml
        ansible-playbook -i inventories/local_development provision_dataservers.yml
        ansible-playbook -i inventories/local_development provision_webservers.yml
    popd
    systemctl disable fairdata-etsin-init
fi

su - etsin-user -c "/usr/local/etsin/search_scripts/reindex_by_recreating_index.sh"
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

su - etsin-user -c "/usr/local/etsin/search_scripts/reindex_by_recreating_index.sh"

pushd /code/etsin_finder
    /usr/local/etsin/pyenv/bin/gunicorn --bind unix:/usr/local/etsin/gunicorn/socket --access-logfile - --error-logfile - --config /etc/gunicorn.py --reload etsin_finder.finder:app
popd

exit 0