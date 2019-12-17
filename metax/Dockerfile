#########################################################
# This file contains the Docker image configuration
# which will enable us to run the Metax service
# inside a container for development and testing purposes.
#
# Author(s):
#RUN echo Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################

################################################
# We base our container on centos with systemd.
FROM cscdevbase:1
WORKDIR /code

ARG metax_password="changeme"
ARG metax_branch="test"
ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

# Create user account for metax
RUN adduser metax-user
RUN groupadd metax
RUN usermod -a -G metax metax-user
RUN echo metax-user:${metax_password} | chpasswd
RUN chown metax-user:metax /code

# deps
RUN yum install ${YUM_ARGS} epel-release python-devel libffi-devel openssl-devel python-pip gcc gcc-c++ patch
RUN yum install ${YUM_ARGS} python-passlib xqilla xqilla-devel ntp htop tcl tree zile
RUN yum install ${YUM_ARGS} python36u python36u-pip python36u-devel

# python modules
RUN cd /code && git clone https://github.com/CSCfi/metax-api.git -b ${metax_branch}

ADD metax-api.diff /metax/metax-api.diff
RUN cd /code/metax-api && patch -p1 < /metax/metax-api.diff

RUN ln -s /code/metax-api /usr/local/metax
RUN mkdir -p /metax
RUN ln -s /code/metax-api /metax/metax-api
RUN python3 -m venv /usr/local/metax/pyenv
RUN source /usr/local/metax/pyenv/bin/activate && pip3 install pip --upgrade
RUN source /usr/local/metax/pyenv/bin/activate && pip3 install setuptools pur wheel


ADD app_config /home/metax-user/app_config
RUN mkdir -p /var/log/metax-api/errors /metax

####
#RUN source /usr/local/metax/pyenv/bin/activate && pur --force --requirement /usr/local/metax/requirements.txt
RUN source /usr/local/metax/pyenv/bin/activate && pip3 install -r /usr/local/metax/requirements.txt

RUN touch /first-time-init


################################################
# NGINX proxy
################################################
RUN yum install ${YUM_ARGS} nginx
RUN mkdir -p /etc/pki/selfsigned/
RUN mkdir -p /etc/nginx/metax/
RUN mkdir -p /etc/pki/web/
RUN openssl dhparam -out /etc/pki/web/dhparam.pem 2048
RUN openssl req -x509 -nodes -subj '/C=FI/ST=Uusimaa/L=Espoo/O=CSC - Tieteen tietotekniikan keskus Oy/CN=metax.csc.local' -days 365 -newkey rsa:2048 -keyout /etc/pki/selfsigned/cert.key -out /etc/pki/selfsigned/cert.crt
ADD nginx/api_response_headers.conf /etc/nginx/metax/
ADD nginx/elastic_headers.conf /etc/nginx/metax/
ADD nginx/static_file_headers.conf /etc/nginx/metax/
ADD nginx/shared_headers.conf /etc/nginx/metax/
ADD nginx/nginx.conf /etc/nginx/

# Add service file to start
RUN systemctl enable nginx

EXPOSE 80
EXPOSE 443
EXPOSE 22

# ensure file permissions

RUN chown -R metax-user:metax /code
RUN chown -R metax-user:metax /home/metax-user
RUN chown -R metax-user:metax /var/log/metax-api

# Add service file to start
RUN mkdir -p /opt/fairdata/metax

ADD service/fairdata-metax-api.sh /opt/fairdata/metax/fairdata-metax-api.sh
ADD service/fairdata-metax-api.service /etc/systemd/system/fairdata-metax-api.service

ADD service/fairdata-metax-api-init.service /etc/systemd/system/fairdata-metax-api-init.service
ADD service/fairdata-metax-api-init.sh /opt/fairdata/metax/fairdata-metax-api-init.sh

RUN chmod +x /opt/fairdata/metax/fairdata-metax-api-init.sh
RUN chmod +x /opt/fairdata/metax/fairdata-metax-api.sh

RUN echo LANG="fi_fi.UTF8" >> /etc/environment
RUN echo LC_CTYPE="fi_FI.UTF8" >> /etc/environment
RUN echo LC_NUMERIC="fi_FI.UTF8" >> /etc/environment
RUN echo LC_TIME="fi_FI.UTF8" >> /etc/environment
RUN echo LC_COLLATE="fi_FI.UTF8" >> /etc/environment
RUN echo LC_MONETARY="fi_FI.UTF8" >> /etc/environment
RUN echo LC_MESSAGES="fi_FI.UTF8" >> /etc/environment
RUN echo LC_PAPER="fi_FI.UTF8" >> /etc/environment
RUN echo LC_NAME="fi_FI.UTF8" >> /etc/environment
RUN echo LC_ADDRESS="fi_FI.UTF8" >> /etc/environment
RUN echo LC_TELEPHONE="fi_FI.UTF8" >> /etc/environment
RUN echo LC_MEASUREMENT="fi_FI.UTF8" >> /etc/environment
RUN echo LC_IDENTIFICATION="fi_FI.UTF8" >> /etc/environment

# Start metax-api on start
RUN systemctl enable fairdata-metax-api
RUN systemctl enable fairdata-metax-api-init


RUN cd /code && git clone https://github.com/CSCfi/metax-ops.git
RUN ln -s /code/metax-ops/ansible /metax/ansible
ADD metax-ops.diff /metax/metax-ops.diff
RUN cd /metax && patch -p1 < metax-ops.diff
RUN cd /metax/ansible && source /usr/local/metax/pyenv/bin/activate && pip3 install ansible
RUN cd /metax/ansible && source /usr/local/metax/pyenv/bin/activate && ansible-playbook provision_cacheservers.yml

################################################
# What to run there inside the container
CMD /usr/sbin/init
