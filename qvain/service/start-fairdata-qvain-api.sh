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


echo
echo "Starting qvain-backend service.."
#########################################################
# start the service
pushd /code/qvain-api/bin
    ./qvain-backend
popd
echo "..backend is now closed."
