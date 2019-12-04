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

VENV:=source venv/bin/activate &&
SHELL:=/bin/bash
NEW_PASSWORD:=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
QVAIN_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 qvain.csc.local | grep -o \(.*\))
METAX_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 metax.csc.local | grep -o \(.*\))
QVAIN_API_BRANCH:=next
QVAIN_JS_BRANCH:=next
METAX_BRANCH:=test

up:	qvain-dev

qvain-dev: test-docker venv
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

	@test -f fairdata-dev-docker-sshkey || ssh-keygen -t rsa -N '' -f fairdata-dev-docker-sshkey
	@test -f cscdevbase/id_rsa.pub || cp fairdata-dev-docker-sshkey.pub cscdevbase/id_rsa.pub
	@test -f .root-password || echo $(NEW_PASSWORD) > .root-password
	-@ssh-keygen -R [localhost]:2222
	-@ssh-keygen -R [localhost]:2223
	@test -d download || git clone https://github.com/CSCfi/fairdata-restricted-download.git download
	@test -d download && (cd download && git pull)
	@cp cscdevbase/id_rsa.pub download/
	@echo "Starting.."
	@echo "ROOT_PASSWORD=$(shell cat .root-password)" > .env
	@echo "SSH_KEY=id_rsa.pub" >> .env
	@echo "QVAIN_API_BRANCH=$(QVAIN_API_BRANCH)" >> .env
	@echo "QVAIN_JS_BRANCH=$(QVAIN_JS_BRANCH)" >> .env
	@echo "QVAIN_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "METAX_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "METAX_BRANCH=$(METAX_BRANCH)" >> .env
	@echo
	@echo "=== Configuration ==="
	@$(VENV) docker-compose config
	@echo "=== end of Configuration ==="
	@$(VENV) docker-compose up --build -d
	@echo
	@echo "After the containers are built, you can login with root:$(shell cat .root-password):"
	@echo "Qvain: ssh root@localhost -p2222 -i fairdata-dev-docker-sshkey"
	@echo "Metax: ssh root@localhost -p2223 -i fairdata-dev-docker-sshkey"
	@echo "Download: ssh root@localhost -p2224 -i fairdata-dev-docker-sshkey"
	@echo
	@./.wait-until-up-qvain
	@echo
	@echo "You should be able to open Qvain with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using fairdata-dev-docker-sshkey.pub"
	@echo

qvain-shell:
	@$(VENV) docker-compose exec qvain.csc.local /bin/bash

qvain-tests:
	@test -d qvain-js || @$(VENV) git clone https://github.com/CSCfi/qvain-js
	@cd qvain-js && git pull && make check

test-docker:
	@echo "Testing connection to Docker.."
	@docker info > /dev/null
	@echo "..ok"

metax-dev: test-docker venv
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
	@test -f fairdata-dev-docker-sshkey || ssh-keygen -t rsa -N '' -f fairdata-dev-docker-sshkey
	@test -f cscdevbase/id_rsa.pub || cp fairdata-dev-docker-sshkey.pub cscdevbase/id_rsa.pub
	@echo "Starting.."
	@echo "ROOT_PASSWORD=$(shell cat .root-password)" > .env
	@echo "METAX_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "METAX_BRANCH=$(METAX_BRANCH)" >> .env
	@echo "SSH_KEY=id_rsa.pub" >> .env
	@echo "METAX_PORT_HTTP=80" >> .env
	@echo "METAX_PORT_HTTPS=443" >> .env
	@echo "=== Configuration ==="
	@$(VENV) docker-compose config
	@echo "=== end of Configuration ==="
	@$(VENV) docker-compose up --build -d metax.csc.local
	@echo
	@echo "After the containers are built, you can login with root:$(shell cat .root-password):"
	@echo "Metax: ssh root@localhost -p2223 -i fairdata-dev-docker-sshkey"
	@echo
	@./.wait-until-up-metax
	@echo
	@echo "You should be able to open Metax API with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using fairdata-dev-docker-sshkey.pub."
	@echo

metax-shell:
	@$(VENV) docker-compose exec metax.csc.local /bin/bash

down:
	$(VENV) docker-compose down

logs:
	$(VENV) docker-compose logs -f

clean:
	$(VENV) docker-compose stop
	$(VENV) docker-compose rm -f
	rm -f .root-password
	ssh-keygen -R [localhost]:2222
	ssh-keygen -R [localhost]:2223
	ssh-keygen -R [localhost]:2224

prune:
	docker image prune
	docker volume prune

venv:
	@python3 -m venv venv
	@$(VENV) pip install -r requirements.txt
