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

ARG etsin_ops_branch="master"
ARG etsin_finder_search_branch="test"
ARG etsin_finder_branch="test"
ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

# instal dependencies
RUN yum ${YUM_ARGS} update
RUN yum ${YUM_ARGS} install patch epel-release python-devel libffi-devel openssl-devel
RUN yum ${YUM_ARGS} install python-pip
RUN pip install pip --upgrade
RUN pip install "ansible>=2.4,<2.5"


# Checkout code and patch it
RUN mkdir -p /code
RUN ln -s /code /etsin

RUN git clone https://github.com/CSCfi/etsin-ops.git -b ${etsin_ops_branch}
RUN git clone https://github.com/CSCfi/etsin-finder.git -b ${etsin_finder_branch} etsin_finder
RUN git clone https://github.com/CSCfi/etsin-finder-search.git -b ${etsin_finder_search_branch} etsin_finder_search

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

ADD 0001-patch-finder-search.patch /code/0001-patch-finder-search.patch
ADD 0001-Do-not-check-source-code-in-provisioning.patch /code/0001-Do-not-check-source-code-in-provisioning.patch
ADD 0001-Patched-for-fairdata-dev-docker.patch /code/0001-Patched-for-fairdata-dev-docker.patch
ADD 0001-Fixed-shell-commands-and-env.patch /code/0001-Fixed-shell-commands-and-env.patch
ADD 0001-Fixed-dataserver-address.patch /code/0001-Fixed-dataserver-address.patch
ADD 0001-Do-not-install-git.patch /code/0001-Do-not-install-git.patch
ADD 0001-Disable-ssl-generation.patch /code/0001-Disable-ssl-generation.patch
ADD 0001-patch-app-config.patch /code/0001-patch-app-config.patch

RUN pushd /code/etsin-ops/ && git am ../0001-Patched-for-fairdata-dev-docker.patch
RUN pushd /code/etsin-ops/ && git am ../0001-Do-not-check-source-code-in-provisioning.patch
RUN pushd /code/etsin-ops/ && git am ../0001-Fixed-shell-commands-and-env.patch
RUN pushd /code/etsin-ops/ && git am ../0001-Fixed-dataserver-address.patch
RUN pushd /code/etsin-ops/ && git am ../0001-Do-not-install-git.patch
#RUN pushd /code/etsin-ops/ && git am ../0001-Disable-ssl-generation.patch
#RUN pushd /code/etsin-ops/ && git am ../0001-patch-app-config.patch
RUN pushd /code/etsin_finder && git am ../0001-patch-finder-search.patch

# Create new user and ensure user permissions
RUN groupadd etsin
RUN useradd -G etsin -ms /bin/bash etsin-user
RUN chown -R etsin-user:etsin /code

# Setup service
RUN mkdir -p /opt/fairdata/etsin
ADD service/fairdata-etsin-init.service /etc/systemd/system/fairdata-etsin-init.service
ADD service/fairdata-etsin-init.sh /opt/fairdata/etsin/fairdata-etsin-init.sh
RUN chmod +x /opt/fairdata/etsin/fairdata-etsin-init.sh

# Setup node 12.x LTS
ADD node-v12.13.1-linux-x64.tar.xz /code/
RUN ln -s /code/node-v12.13.1-linux-x64/bin/node /usr/local/bin/node
RUN ln -s /code/node-v12.13.1-linux-x64/bin/npm /usr/local/bin/npm
ENV PATH=/code/node-v12.13.1-linux-x64/bin:${PATH}

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

# Start etsin-init on start
RUN systemctl enable fairdata-etsin-init

RUN echo "etsin-user ALL=NOPASSWD: ALL" >> /etc/sudoers

# Place SSL certs
ADD redirect-server.crt /etc/nginx/ssl_certs/redirect-nginx-selfsigned.crt
ADD redirect-server.pem /etc/nginx/ssl_certs/redirect-nginx-selfsigned.key
ADD server.crt /etc/nginx/ssl_certs/nginx-selfsigned.crt
ADD server.pem /etc/nginx/ssl_certs/nginx-selfsigned.key

# Enable the provision on container boot
RUN touch /code/first-time-init


EXPOSE 80
EXPOSE 443

################################################
# What to run there inside the container
CMD /usr/sbin/init
