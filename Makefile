#########################################################
# This file contains make targets which will help
# how to use things.
#
# Author(s):
#      Juhapekka Piiroinen <juhapekka.piiroinen@csc.fi>
#
# (C) 2019 Copyright CSC - IT Center for Science Ltd.
# All Rights Reserved.
#########################################################

SHELL:=/bin/bash
NEW_PASSWORD:=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
QVAIN_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 qvain.csc.local | grep -o \(.*\))
METAX_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 metax.csc.local | grep -o \(.*\))

up:	qvain-dev

qvain-dev:
ifeq ($(QVAIN_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   qvain.csc.local"
	@echo
	@read
else
	@echo
	@echo " qvain.csc.local was resolved to 127.0.0.1."
	@echo
endif

	@test -f qvain/env || (cp qvain/env.template qvain/env && nano qvain/env)
	@test -f cscdevbase/id_rsa.pub || cp ~/.ssh/id_rsa.pub cscdevbase/
	@test -f .root-password || echo $(NEW_PASSWORD) > .root-password
	-@ssh-keygen -R [localhost]:2222
	-@ssh-keygen -R [localhost]:2223
	@test -d download || git clone https://github.com/CSCfi/fairdata-restricted-download.git download
	@test -d download && (cd download && git pull)
	@cp cscdevbase/id_rsa.pub download/
	@echo "Starting.."
	@ROOT_PASSWORD=$(NEW_PASSWORD) SSH_KEY=id_rsa.pub docker-compose up --build -d
	@echo
	@echo "After the containers are built, you can login with root:$(NEW_PASSWORD):"
	@echo "Qvain: ssh root@localhost -p2222"
	@echo "Metax: ssh root@localhost -p2223"
	@echo "Download: ssh root@localhost -p2224"
	@echo
	@./.wait-until-up-qvain
	@echo
	@echo "You should be able to open Qvain with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using your public key in ~/.ssh/id_rsa.pub"
	@echo

metax-dev:
ifeq ($(METAX_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   metax.csc.local"
	@echo
	@read
else
	@echo
	@echo " metax.csc.local was resolved to 127.0.0.1."
	@echo
endif

	@test -f .root-password || echo $(NEW_PASSWORD) > .root-password
	@echo "Starting.."
	@ROOT_PASSWORD=$(NEW_PASSWORD) SSH_KEY=id_rsa.pub METAX_PORT_HTTP=80 METAX_PORT_HTTPS=443 docker-compose up --build -d metax.csc.local
	@echo
	@echo "After the containers are built, you can login with root:$(NEW_PASSWORD):"
	@echo "Metax: ssh root@localhost -p2223"
	@echo
	@./.wait-until-up-metax
	@echo
	@echo "You should be able to open Metax API with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using your public key in ~/.ssh/id_rsa.pub"
	@echo

down:
	docker-compose down

logs:
	docker-compose logs -f

clean:
	docker-compose stop
	docker-compose rm -f
	rm -f .root-password
	-docker image rm `docker image ls qvain -q`
	ssh-keygen -R [localhost]:2222
	ssh-keygen -R [localhost]:2223
	ssh-keygen -R [localhost]:2224
