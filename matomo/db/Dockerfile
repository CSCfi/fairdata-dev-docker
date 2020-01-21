#########################################################
# This file contains the Docker image configuration
# which will enable us to run the Matomo DB service
# inside a container for development and testing purposes.
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2020 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################

FROM mariadb
ADD matomo.sql /
ADD init-matomo-db.sh /
RUN chmod +x /init-matomo-db.sh
