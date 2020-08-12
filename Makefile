DOCKER_COMPOSE = docker-compose -f docker-compose.yml
BUNDLE_FLAGS=

ifdef DEPLOYMENT
  BUNDLE_FLAGS = --without test development
endif

DOCKER_BUILD_CMD = BUNDLE_INSTALL_FLAGS="$(BUNDLE_FLAGS)" $(DOCKER_COMPOSE) build

build:
	docker build -t docker_admin . --build-arg RACK_ENV --build-arg DB_HOST --build-arg DB_USER --build-arg DB_PASS --build-arg SECRET_KEY_BASE --build-arg DB_NAME

start-db:
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql

db-setup: start-db
	$(DOCKER_COMPOSE) run --rm app ./bin/rails db:create db:schema:load db:seed

serve: stop start-db
	$(DOCKER_COMPOSE) up app

shell:
	$(DOCKER_COMPOSE) run --rm app sh

stop:
	$(DOCKER_COMPOSE) down -v

deploy: build
	echo ${SECRET_KEY_BASE}
	echo ${REGISTRY_URL}
	aws ecr get-login-password | docker login --username AWS --password-stdin ${REGISTRY_URL}
	docker tag docker_admin:latest ${REGISTRY_URL}/${ENV}-admin:latest
	docker push ${REGISTRY_URL}/${ENV}-admin:latest

.PHONY: build serve stop test deploy
