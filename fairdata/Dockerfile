#########################################################
# This file contains the Docker image configuration
# which will enable us to run the Etsin service
# inside a container for development and testing purposes.
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################

################################################
# We base our container on centos with systemd.
FROM cscdevbase:1
WORKDIR /code
SHELL [ "/bin/bash", "-c" ]

ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

RUN yum ${YUM_ARGS} install nginx
RUN systemctl enable nginx
RUN mkdir -p /etc/pki/selfsigned/
RUN mkdir -p /etc/pki/web/
RUN openssl dhparam -out /etc/pki/web/dhparam.pem 2048
RUN openssl req -x509 -nodes -subj '/C=FI/ST=Uusimaa/L=Espoo/O=CSC - Tieteen tietotekniikan keskus Oy/CN=qvain.csc.local' -days 365 -newkey rsa:2048 -keyout /etc/pki/selfsigned/cert.key -out /etc/pki/selfsigned/cert.crt

RUN mkdir -p /code/www
RUN rm -Rf /usr/share/nginx/html
ADD . /code
RUN ln -s /code/www /usr/share/nginx/html
RUN rm -f /etc/nginx/nginx.conf
RUN ln -s /code/nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
EXPOSE 443

################################################
# What to run there inside the container
CMD /usr/sbin/init
