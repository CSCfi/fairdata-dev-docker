#########################################################
# This file contains the Docker image configuration
# which will enable us to run the Qvain service
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
SHELL [ "/bin/bash", "-c" ]

ARG etsin_ops_branch="master"
ARG etsin_finder_search_branch="test"
ARG etsin_finder_branch="test"
ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

# install dependencies
#RUN yum ${YUM_ARGS} install http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
ADD keys /code/keys
RUN cd /code/keys && rpm --import RPM-GPG-KEY-remi RPM-GPG-KEY-remi2017 RPM-GPG-KEY-remi2018 RPM-GPG-KEY-remi2019 rabbitmq-release-signing-key.asc

RUN yum-config-manager --add-repo https://dl.bintray.com/rabbitmq/rpm/rabbitmq-server/v3.8.x/el/7/
RUN yum-config-manager --add-repo https://dl.bintray.com/rabbitmq-erlang/rpm/erlang/22/el/7/

#RUN yum-config-manager --enable remi-php73
RUN yum ${YUM_ARGS} update
RUN yum ${YUM_ARGS} remove postgresql
RUN yum ${YUM_ARGS} install curl mailx bindfs
RUN yum ${YUM_ARGS} install centos-release-scl.noarch 
RUN yum ${YUM_ARGS} install rh-postgresql96 rh-postgresql96-syspaths
ENV LD_LIBRARY_PATH=/opt/rh/rh-postgresql96/root/usr/lib64
RUN yum ${YUM_ARGS} install rh-php71 rh-php71-php rh-php71-php-fpm httpd rh-php71 rh-php71-php rh-php71-php-gd rh-php71-php-mbstring rh-php71-php-pgsql rh-php71-php-pdo rh-php71-php-mcrypt rh-php71-php-xml rh-php71-php-json rh-php71-php-xmlrpc rh-php71-php-bcmath rh-php71-php-pecl-redis rh-php71-php-amqp rh-php71-php-pecl-zip rh-php71-php-posix rh-php71-php-soap rh-php71-php-intl rh-php71-php-pecl-apcu
RUN yum ${YUM_ARGS} install python-pip python-devel
RUN yum ${YUM_ARGS} install httpd redis mod_ssl
RUN yum ${YUM_ARGS} install bc
RUN pip install pip --upgrade

RUN systemctl enable rh-postgresql96-postgresql

RUN systemctl enable rh-php71-php-fpm
RUN ln -s /opt/rh/httpd24/root/etc/httpd/conf.d/rh-php71-php.conf /etc/httpd/conf.d/
RUN ln -s /opt/rh/httpd24/root/etc/httpd/conf.modules.d/15-rh-php71-php.conf /etc/httpd/conf.modules.d/
RUN ln -s /opt/rh/httpd24/root/etc/httpd/modules/librh-php71-php7.so /etc/httpd/modules/
RUN ln -s /opt/rh/rh-php71/root/usr/bin/php /usr/bin/php

ADD service/fairdata-ida-init.service /etc/systemd/system/
ADD service/fairdata-ida-init.sh /opt/fairdata/ida/
RUN chmod +x /opt/fairdata/ida/fairdata-ida-init.sh

RUN systemctl enable fairdata-ida-init

RUN mkdir -p /mnt/storage_vol01/ida
RUN mkdir -p /mnt/storage_vol01/log
RUN mkdir -p /mnt/storage_vol02/ida
RUN mkdir -p /mnt/storage_vol02/ida_replication
RUN mkdir -p /mnt/storage_vol02/ida_trash
RUN mkdir -p /mnt/rabbitmq_monitoring
RUN chown -R apache:apache /mnt/storage_vol01
RUN chown -R apache:apache /mnt/storage_vol02
RUN chown -R apache:apache /mnt/rabbitmq_monitoring

RUN touch /code/first-time-init

RUN git clone https://github.com/CSCfi/ida2.git ida

ADD patches/0001-allow-remote-rabbitmq.patch /code/0001-allow-remote-rabbitmq.patch
RUN cd /code/ida && git am ../0001-allow-remote-rabbitmq.patch
RUN git clone https://github.com/CSCfi/ida2-command-line-tools.git ida-tools
ADD ida2-csc-service /code/ida-service

#RUN mkdir -p /var/ida /var/ida-tools /var/ida-service
RUN ln -s /code/ida /var/ida
RUN ln -s /code/ida-tools /var/ida-tools
RUN ln -s /code/ida-service /var/ida-service
RUN chown -R apache:apache /code

ADD config/httpd.conf /etc/httpd/conf/httpd.conf
ADD config/ssl.conf /etc/httpd/conf.d/ssl.conf

RUN mkdir -p /etc/httpd/ssl
ADD server.crt /etc/httpd/ssl/localhost.crt
ADD server.pem /etc/httpd/ssl/localhost.key
RUN systemctl enable httpd

RUN echo "bind 127.0.0.1" >> /etc/redis.conf
RUN systemctl enable redis

RUN mkdir -p /var/ida/nextcloud/config
RUN chown -R apache:apache /var/ida/nextcloud/

ADD config/config.php /code/config.php.template
ADD config/config.sh /code/config.sh

RUN mkdir -p /srv/venv-agents
RUN chmod 777 /srv/venv-agents
RUN yum ${YUM_ARGS} install python3 python3-devel
RUN python3 -m venv /srv/venv-agents
RUN chown -R apache:apache /srv/venv-agents

RUN ln -s /var/ida/agents/services/rabbitmq-metadata-agent.service /etc/systemd/system/rabbitmq-metadata-agent.service
RUN ln -s /var/ida/agents/services/rabbitmq-replication-agent.service /etc/systemd/system/rabbitmq-replication-agent.service
RUN systemctl enable rabbitmq-metadata-agent
RUN systemctl enable rabbitmq-replication-agent

ADD uni2ascii-4.18.tar.bz2 /code/
RUN cd /code/uni2ascii-4.18 && ./configure --disable-dependency-tracking && make install
RUN ln -s /usr/local/bin/ascii2uni /usr/bin/ascii2uni
RUN ln -s /usr/local/bin/uni2ascii /usr/bin/uni2ascii

RUN yum ${YUM_ARGS} install rabbitmq-server
RUN systemctl disable rabbitmq-server

RUN echo "supersecret" > /var/lib/rabbitmq/.erlang.cookie
RUN chmod 700 /var/lib/rabbitmq/.erlang.cookie
RUN chown rabbitmq:rabbitmq /var/lib/rabbitmq/.erlang.cookie

EXPOSE 80
EXPOSE 443
EXPOSE 4433

################################################
# What to run there inside the container
CMD /usr/sbin/init
