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
DOCKER_COMPOSE:=$(VENV) COMPOSE_HTTP_TIMEOUT=2000 docker-compose
OPENSSL_IN_PATH:=export OPENSSL_CONF="$(PWD)/openssl-1.1.1/build/openssl.cnf" && export PATH="$(PWD)/openssl-1.1.1/build/bin:$(PATH)" &&
SHELL:=/bin/bash
QVAIN_API_BRANCH:=next
QVAIN_JS_BRANCH:=next
METAX_BRANCH:=test
ETSIN_BRANCH:=test
HYDRA:=$(DOCKER_COMPOSE) exec auth.csc.local hydra
RESOLVE_HOST:=localhost
RESOLVE_IP:=127.0.0.1

all: dev

up:	all

update: update-hydra-login-consent-node

resolve: resolve-info resolve-simplesaml resolve-download resolve-fairdata resolve-etsin resolve-metax resolve-qvain resolve-auth resolve-auth-consent resolve-ida
	@echo

new_password:
	$(eval NEW_PASSWORD:=$(shell cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) )

resolve_to:
ifneq ("$(shell ping -q -c 1 -t 1 $(RESOLVE_HOST) | grep -o \(.*\) | tr -d '(' | tr -d ')')","$(RESOLVE_IP)")
	@echo
	@echo "You need to add following line to /etc/hosts on your machine:"
	@echo "  $(RESOLVE_IP)   $(RESOLVE_HOST)"
	@echo
	@echo "Press <enter> to continue or <ctrl+c> to cancel."
	@read
else
	@echo " $(RESOLVE_HOST) was resolved to $(RESOLVE_IP)."
endif

resolve-info:
	@echo
	@echo "Testing that following addresses are resolved correctly:"
	@echo "  127.0.0.1   metax.csc.local"
	@echo "  127.0.0.1   auth-consent.csc.local"
	@echo "  127.0.0.1   auth.csc.local"
	@echo "  127.0.0.1   qvain.csc.local"
	@echo "  127.0.0.1   etsin.csc.local"
	@echo "  127.0.0.1   fairdata.csc.local"
	@echo "  127.0.0.1   simplesaml.csc.local"
	@echo "  127.0.0.1   download.csc.local"
	@echo "  127.0.0.1   ida.csc.local"
	@echo

resolve-etsin:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=etsin.csc.local resolve_to

resolve-metax:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=metax.csc.local resolve_to

resolve-auth-consent:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=auth-consent.csc.local resolve_to

resolve-auth:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=auth.csc.local resolve_to

resolve-qvain:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=qvain.csc.local resolve_to

resolve-fairdata:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=fairdata.csc.local resolve_to

resolve-simplesaml:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=simplesaml.csc.local resolve_to

resolve-download:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=download.csc.local resolve_to

resolve-ida:
	@make RESOLVE_IP=127.0.0.1 RESOLVE_HOST=ida.csc.local resolve_to

qvain-dev: new_password resolve test-docker venv config
	@$(DOCKER_COMPOSE) up --build -d
	@echo
	@echo Setup and test authentication service..
	@make auth-wait
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
	@make qvain-wait
	@echo
	@echo "You should be able to open Qvain with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using fairdata-dev-docker-sshkey.pub"
	@echo

qvain-shell: venv
	@$(DOCKER_COMPOSE) exec qvain.csc.local /bin/bash

qvain-tests:
	@test -d qvain-js || git clone https://github.com/CSCfi/qvain-js -b next
	@cd qvain-js && git pull && make check

simplesaml-dev: new_password resolve test-docker venv config
	@$(DOCKER_COMPOSE) up --build -d simplesaml.csc.local

simplesaml-shell: venv
	@$(DOCKER_COMPOSE) exec simplesaml.csc.local /bin/bash

etsin-dev: new_password resolve test-docker venv config
	@$(DOCKER_COMPOSE) up --build -d etsin.csc.local
	@echo
	@echo Setup and test authentication service..
	@make simplesaml-wait
	@echo "..auth is setup!"
	@echo
	@echo "After the containers are built, you can login with root:$(shell cat .root-password):"
	@echo "Etsin: ssh root@localhost -p2225 -i fairdata-dev-docker-sshkey"
	@echo "Metax: ssh root@localhost -p2223 -i fairdata-dev-docker-sshkey"
	@echo "Download: ssh root@localhost -p2224 -i fairdata-dev-docker-sshkey"
	@echo
	@echo "You can also use make commands to directly get into the shell without ssh."
	@echo "Etsin: make etsin-shell"
	@echo "Metax: make metax-shell"
	@echo "Download: make download-shell"
	@echo
	@make etsin-wait
	@echo
	@echo "You should be able to open Etsin with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using fairdata-dev-docker-sshkey.pub"
	@echo

etsin-shell: venv
	@$(DOCKER_COMPOSE) exec etsin.csc.local /bin/bash

etsin-logs: venv
	@$(DOCKER_COMPOSE) exec etsin.csc.local /usr/bin/journalctl -fu fairdata-etsin-init -n 1000

download-shell: venv
	@$(DOCKER_COMPOSE) exec download.csc.local /bin/bash

test-docker:
	@echo "Testing connection to Docker.."
	@docker info > /dev/null
	@echo "..ok"

metax-dev: resolve config test-docker venv
	@$(DOCKER_COMPOSE) up --build -d metax.csc.local
	@echo
	@echo "After the containers are built, you can login with root:$(shell cat .root-password):"
	@echo "Metax: ssh root@localhost -p2223 -i fairdata-dev-docker-sshkey"
	@echo
	@make metax-wait
	@echo
	@echo "You should be able to open Metax API with your web browser:"
	@echo " http://127.0.0.1"
	@echo " https://127.0.0.1"
	@echo
	@echo "There should be also public key authentication setup using fairdata-dev-docker-sshkey.pub."
	@echo

metax-shell: venv
	@$(DOCKER_COMPOSE) exec metax.csc.local /bin/bash

metax-wait:
	@./.wait-until-up "metax web interface" metax.csc.local 1443 https://metax.csc.local:1443/rest/datasets

ida-shell: venv
	@$(DOCKER_COMPOSE) exec ida.csc.local /bin/bash

qvain-wait:
	@./.wait-until-up "qvain web interface" qvain.csc.local 3443 https://qvain.csc.local:3443/api/auth/login

etsin-wait:
	@./.wait-until-up "etsin web interface" etsin.csc.local 4443 https://etsin.csc.local:4443/

simplesaml-wait:
	@./.wait-until-up "simplesaml web interface" simplesaml.csc.local 2080

ida-wait:
	@./.wait-until-up "ida web interface" ida.csc.local 5080

ida/ida2-csc-service:
	@test -d ida/ida2-csc-service || (cd ida && git clone --depth 1 git@github.com:CSCfi/ida2-csc-service.git)

auth-wait:
	@./.wait-until-up "auth interface" auth.csc.local 4444
	@./.wait-until-up "auth admin interface" auth.csc.local 4445
	@echo -n " - creating endpoint for qvain.."
	-@$(HYDRA) clients delete fuubarclientid --endpoint http://127.0.0.1:4445 > /dev/null
	-@$(HYDRA) clients create --endpoint http://127.0.0.1:4445 --id fuubarclientid --secret changeme --grant-types authorization_code,refresh_token --response-types code,id_token --scope openid,offline,profile,email --callbacks https://qvain.csc.local:3443/api/auth/cb --post-logout-callbacks https://qvain.csc.local:3443/ > /dev/null
	@echo "..created!"

download-wait:
	@./.wait-until-up "download interface" download.csc.local 8433

fairdata-wait: simplesaml-wait auth-wait download-wait metax-wait etsin-wait qvain-wait ida-wait
	@./.wait-until-up "fairdata developer web interface" fairdata.csc.local 80

down: venv hydra-login-consent-node download
	-@$(DOCKER_COMPOSE) down -v 2> /dev/null

logs: venv
	@$(DOCKER_COMPOSE) logs -f

clean: venv
	-@$(DOCKER_COMPOSE) down --rmi all 2>&1 /dev/null
	-@cd openssl-1.1.1 && make clean
	-@rm -rf hydra-login-consent-node .root-password download node-v12.13.1-linux-x64.tar.xz etsin/node-v12.13.1-linux-x64.tar.xz simplesaml/node-v12.13.1-linux-x64.tar.xz

hydra-login-consent-node:
	@git clone https://github.com/CSCfi/fairdata-hydra-login-consent-node.git hydra-login-consent-node

prune:
	-@./.docker-clean-up 2>&1 /dev/null

venv:
	@python3 -m venv venv
	@$(VENV) pip install -r requirements.txt

download:
	@test -d download || git clone https://github.com/CSCfi/fairdata-restricted-download.git download > /dev/null
	@test -d download && (cd download && git pull) > /dev/null

certs: openssl-1.1.1/build/bin
	@$(OPENSSL_IN_PATH) cd etsin      && make certs
	@$(OPENSSL_IN_PATH) cd qvain      && make certs
	@$(OPENSSL_IN_PATH) cd fairdata   && make certs
	@$(OPENSSL_IN_PATH) cd ida        && make certs
	@$(OPENSSL_IN_PATH) cd simplesaml && make certs
	@$(OPENSSL_IN_PATH) cd metax      && make certs

config: venv new_password download hydra-login-consent-node ida/ida2-csc-service certs
	@echo "=== Configuring workspace ======================"
	@echo -n " - Downloading dependencies.."
	@test -f node-v12.13.1-linux-x64.tar.xz || curl -O https://nodejs.org/dist/v12.13.1/node-v12.13.1-linux-x64.tar.xz > /dev/null
	@test -f simplesaml/node-v12.13.1-linux-x64.tar.xz || (pushd simplesaml && cp ../node-v12.13.1-linux-x64.tar.xz .) > /dev/null
	@test -f etsin/node-v12.13.1-linux-x64.tar.xz || (pushd etsin && cp ../node-v12.13.1-linux-x64.tar.xz .)
	@echo "..downloaded!"

	@echo -n " - Setting up environments and ssh keys.."
	@test -f qvain/env || (cp qvain/env.template qvain/env)
	@test -f etsin/env || (cp etsin/env.template etsin/env)
	@test -f .root-password || echo $(NEW_PASSWORD) > .root-password
	@test -f fairdata-dev-docker-sshkey || ssh-keygen -t rsa -N '' -f fairdata-dev-docker-sshkey
	@test -f cscdevbase/id_rsa.pub || cp fairdata-dev-docker-sshkey.pub cscdevbase/id_rsa.pub
	@test -f download/id_rsa.pub || cp fairdata-dev-docker-sshkey.pub download/id_rsa.pub

	@echo "ROOT_PASSWORD=$(shell cat .root-password)" > .env
	@echo "QVAIN_API_BRANCH=$(QVAIN_API_BRANCH)" >> .env
	@echo "QVAIN_JS_BRANCH=$(QVAIN_JS_BRANCH)" >> .env
	@echo "QVAIN_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "METAX_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "METAX_BRANCH=$(METAX_BRANCH)" >> .env
	@echo "ETSIN_BRANCH=$(ETSIN_BRANCH)" >> .env
	@echo "ETSIN_PASSWORD=$(shell cat .root-password)" >> .env
	@echo "SSH_KEY=id_rsa.pub" >> .env
	@echo "METAX_PORT_HTTP=1080" >> .env
	@echo "METAX_PORT_HTTPS=1443" >> .env
	@echo "QVAIN_PORT_HTTP=3080" >> .env
	@echo "QVAIN_PORT_HTTPS=3443" >> .env
	@echo "ETSIN_PORT_HTTP=4080" >> .env
	@echo "ETSIN_PORT_HTTPS=4443" >> .env
	@echo "AUTH_CONSENT_PORT=3000" >> .env
	@echo "DOWNLOAD_PORT=8433" >> .env
	@echo "AUTH_PUBLIC_PORT=4444" >> .env
	@echo "AUTH_ADMIN_PORT=4445" >> .env
	@echo "AUTH_TOKEN_PORT=5555" >> .env
	@echo "SAML_PORT_HTTPS=2443" >> .env
	@echo "SAML_PORT_HTTP=2080" >> .env
	@echo "IDA_PORT_HTTPS=5443" >> .env
	@echo "IDA_PORT_HTTP=5080" >> .env
	@echo "IDA_PORT_ALT_HTTPS=5433" >> .env
	@echo "..setup complete."

	@echo " - Using following docker configuration:"
	@echo "---8<---"
	@$(DOCKER_COMPOSE) config
	@echo "---8<---"
	@echo "=== Workspace has been configured =============="
	@echo

dev: down clean-code fairdata-dev

rebuild: down prune dev

clean-code:
	-@./.docker-clean-up-code 2> /dev/null

fairdata-dev: venv resolve config
	@echo "=== Building containers ========================"
	@$(DOCKER_COMPOSE) up --build -d fairdata.csc.local
	@echo "=== Containers have been built! ================"
	@echo
	@echo "=== Booting and waiting for services ==========="
	@make fairdata-wait
	@echo "=== Everything is up and running. =============="
	@echo
	@echo " Open your browser to https://fairdata.csc.local/"
	@echo " It has the developer related links."
	@echo

openssl-1.1.1/build/bin:
	@openssl version|grep 1.1|wc -l || (cd openssl-1.1.1 && make)
