#!/bin/bash
#########################################################
# This file contains script to import initial database
# for Matomo use.
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2020 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################

/usr/bin/mysql -u matomo -pchangeme matomo_database < /matomo.sql
