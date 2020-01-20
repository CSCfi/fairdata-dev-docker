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

ARG SIMPLESAML_BRANCH="master"
ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

# install dependencies
RUN yum ${YUM_ARGS} update
RUN yum ${YUM_ARGS} install centos-release-scl.noarch
RUN yum ${YUM_ARGS} install nodejs rh-php72 rh-php72-php rh-php72-php-fpm httpd rh-php72 rh-php72-php rh-php72-php-gd rh-php72-php-mbstring rh-php72-php-intl rh-php72-php-pecl-apcu

RUN systemctl enable rh-php72-php-fpm
RUN ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php72-php.conf /etc/httpd/conf.d/
RUN ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php72-php.conf /etc/httpd/conf.modules.d/
RUN ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php72-php7.so /etc/httpd/modules/
RUN ln -s /opt/rh/rh-php72/root/usr/bin/php /usr/bin/php
RUN systemctl enable httpd

RUN systemctl enable sshd
RUN systemctl enable dbus
RUN systemctl enable rsyslog
RUN systemctl enable crond

# Install PHP Composer
# https://getcomposer.org/download/
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
RUN php -r "if (hash_file('sha384', 'composer-setup.php') === 'c5b9b6d368201a9db6f74e2611495f369991b72d9c8cbd3ffbc63edff210eb73d46ffbfce88669ad33695ef77dc76976') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
RUN php composer-setup.php --install-dir=/usr/local/bin
RUN php -r "unlink('composer-setup.php');"

# Install nodejs
ADD node-v12.13.1-linux-x64.tar.xz /code/
RUN rm -f /usr/bin/node /usr/bin/npm /usr/bin/npx
RUN ln -s /code/node-v12.13.1-linux-x64/bin/node /usr/bin/node
RUN ln -s /code/node-v12.13.1-linux-x64/bin/npm /usr/bin/npm
RUN ln -s /code/node-v12.13.1-linux-x64/bin/npx /usr/bin/npx

# Checkout code and patch it
RUN mkdir -p /code
RUN git clone https://github.com/simplesamlphp/simplesamlphp.git -b ${SIMPLESAML_BRANCH} simplesamlphp

# Create new user and ensure user permissions
RUN groupadd simplesaml
RUN useradd -G simplesaml -ms /bin/bash simplesaml-user
RUN chown -R simplesaml-user:simplesaml /code

RUN ln -s /code/simplesamlphp /var/simplesamlphp

USER simplesaml-user

WORKDIR /code/simplesamlphp
RUN git checkout 1f9ce0a7197044f98aaa66ad0d6ae7f65add2a86
RUN cp -r config-templates/* config/
RUN cp -r metadata-templates/* metadata/

RUN php /usr/local/bin/composer.phar install
RUN npm install
RUN npm run build

ADD configs/simplesaml.conf /etc/httpd/conf.d/simplesaml.conf
ADD configs/config.php /code/simplesamlphp/config/config.php
ADD configs/authsources.php /code/simplesamlphp/config/authsources.php

RUN mkdir -p /code/simplesamlphp/cert/
ADD server.crt /code/simplesamlphp/cert/server.crt
ADD server.pem /code/simplesamlphp/cert/server.pem
RUN touch /var/simplesamlphp/modules/exampleauth/enable

USER root

WORKDIR /code

EXPOSE 80
EXPOSE 443

################################################
# What to run there inside the container
CMD /usr/sbin/init
