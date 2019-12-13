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

#########################################################
# Do the first time start up related initializations and system
# preparing which will take care that the database itself
# has the required databases and schemas.
if [[ -f /first-time-init ]]; then

    echo "Waiting until postgresql server is ready.."
    while true; do
        nc ${PGHOST} 5432 -z -w 59 2> /dev/null
        if [[ $? == 0 ]]; then
            break
        fi
    done
    echo "..ok"
    echo

    echo "Initializing qvain database.."
    # initialize the database with qvain api schema
    psql --file=/code/qvain-api/schema/schema.sql
    echo "..database ok."
    echo

    echo "Removing temporary file.."
    # ensure that we wont run these after the first time
    rm -f /first-time-init
    echo "..ok"
fi

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

echo
echo "Starting qvain-backend service.."
#########################################################
# start the service
pushd /code/qvain-api/bin
    ./qvain-backend
popd
echo "..backend is now closed."
