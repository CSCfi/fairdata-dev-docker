#!/bin/bash
#########################################################
# This file is the startup file for the Etsin service
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

echo "Starting etsin_finder.."
pushd /code/etsin_finder
    /usr/local/etsin/pyenv/bin/gunicorn --bind unix:/usr/local/etsin/gunicorn/socket --access-logfile - --error-logfile - --config /etc/gunicorn.py --reload etsin_finder.finder:app
popd
echo "..done."
echo