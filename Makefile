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
AUTH_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 auth.csc.local | grep -o \(.*\))
AUTH_CONSENT_CSC_LOCAL:=$(shell ping -q -c 1 -t 1 auth-consent.csc.local | grep -o \(.*\))
QVAIN_API_BRANCH:=next
QVAIN_JS_BRANCH:=next
METAX_BRANCH:=test
HYDRA:=docker-compose exec auth.csc.local hydra

up:	code qvain-dev

code:
	mkdir -p code

resolve: resolve-info resolve-metax resolve-qvain resolve-auth resolve-auth-consent
	@echo

resolve-info:
	@echo
	@echo "Testing that following addresses are resolved correctly:"
	@echo "  127.0.0.1   metax.csc.local"
	@echo "  127.0.0.1   auth-consent.csc.local"
	@echo "  127.0.0.1   auth.csc.local"
	@echo "  127.0.0.1   qvain.csc.local"
	@echo	

resolve-metax:
ifeq ($(METAX_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   metax.csc.local"
	@echo
	@read
else
	@echo " metax.csc.local was resolved to 127.0.0.1."
endif

resolve-auth-consent:
ifeq ($(AUTH_CONSENT_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   auth-consent.csc.local"
	@read
else
	@echo " auth-consent.csc.local was resolved to 127.0.0.1."
endif

resolve-auth:
ifeq ($(AUTH_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   auth.csc.local"
	@echo
	@read
else
	@echo " auth.csc.local was resolved to 127.0.0.1."
endif

resolve-qvain:
ifeq ($(QVAIN_CSC_LOCAL),"(127.0.0.1)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  127.0.0.1   qvain.csc.local"
	@echo
	@read
else
	@echo " qvain.csc.local was resolved to 127.0.0.1."
endif

qvain-dev: resolve test-docker venv
	@test -d hydra-login-consent-node || git clone https://github.com/jppiiroinen/hydra-login-consent-node.git

	@test -f qvain/env || (cp qvain/env.template qvain/env)

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
	@echo Setup and test authentication service..
	@./.wait-until-up-auth
	-@$(HYDRA) clients create --endpoint http://127.0.0.1:4445 --id fuubarclientid --secret changeme --grant-types authorization_code,refresh_token --response-types code,id_token --scope openid,offline,profile,email --callbacks https://qvain.csc.local/api/auth/cb
	@echo "..auth is setup!"
	@echo
	@echo "After the containers are built, you can login with root:$(shell cat .root-password):"
	@echo "Qvain: ssh root@localhost -p2222 -i fairdata-dev-docker-sshkey"
	@echo "Metax: ssh root@localhost -p2223 -i fairdata-dev-docker-sshkey"
	@echo "Download: ssh root@localhost -p2224 -i fairdata-dev-docker-sshkey"
	@echo
	@echo "You can also use make commands to directly get into the shell without ssh."
	@echo "Qvain: make qvain-shell"
	@echo "Metax: make metax-shell"
	@echo "Download: make download-shell"
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
	@test -d qvain-js || git clone https://github.com/CSCfi/qvain-js -b next
	@cd qvain-js && git pull && make check

download-shell:
	@$(VENV) docker-compose exec download.csc.local /bin/bash

test-docker:
	@echo "Testing connection to Docker.."
	@docker info > /dev/null
	@echo "..ok"

metax-dev: resolve test-docker venv
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
	rm -rf .root-password qvain-js
	ssh-keygen -R [localhost]:2222
	ssh-keygen -R [localhost]:2223
	ssh-keygen -R [localhost]:2224

prune:
	docker image prune
	docker volume prune

venv:
	@python3 -m venv venv
	@$(VENV) pip install -r requirements.txt
