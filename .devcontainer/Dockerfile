#########################################################
# License: MIT
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################
FROM cscdevbase:1
WORKDIR /code
ARG YUM_ARGS="--setopt=tsflags=nodocs -y"

RUN yum install ${YUM_ARGS} golang postgresql gcc gcc-c++ patch
RUN yum remove ${YUM_ARGS} git*
RUN yum install ${YUM_ARGS} https://centos7.iuscommunity.org/ius-release.rpm
RUN yum install ${YUM_ARGS} git2u-all golang golang-bin
RUN yum install ${YUM_ARGS} npm
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
RUN source ~/.bashrc && nvm install --lts=dubnium
RUN rm -f /root/.gitconfig
CMD /usr/sbin/init
