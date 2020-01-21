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

#########################################################
# Do the first time start up related initializations and system
# preparing which will take care that the database itself
# has the required databases and schemas.

echo "Setting up ssh authentication to localhost for dev use.."
if [[ ! -f ~/.ssh/id_rsa ]]; then
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''
fi
cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys
screen -d -m ssh -o 'StrictHostKeyChecking=no' -L9200:elasticsearch.csc.local:9200 127.0.0.1 -N
echo "..ssh ok."
echo
echo "Waiting for elasticsearch is available.."
# lets wait for awhile to ensure that elasticsearch is up
set +e
while true; do
    nc 127.0.0.1 9200 -z -w 59 2> /dev/null
    if [[ $? == 0 ]]; then
        break
    fi
done
set -e
echo "..elasticsearch has been started."
echo
echo "Wait until metax preparations are done.."
while [ -f /first-time-init ]; do
  sleep 1
done
echo "..looks good."
echo

#########################################################
# start the service
echo "Starting metax development server.."
pushd /code/metax-api/src
    source /usr/local/metax/pyenv/bin/activate && python3 manage.py runserver 0.0.0.0:8000
popd
echo "..service is now shut down."
