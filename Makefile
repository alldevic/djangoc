#!/usr/bin/make

.PHONY: pgadmin up down logs sh migrations migrate static su
.PHONY: ruff-format djlint clean install lint format prune ruff shell
.PHONY: build mypy pre-commit dozzle rui
.DEFAULT_GOAL := lint

include ./.env

SHELL = /bin/bash

CURRENT_UID := $(shell id -u):$(shell id -g)
MAIN_COMPOSE=-f ./docker/docker-compose.yml
PGADMIN_COMPOSE=-f ./tools/pgadmin4/docker-compose.pgadmin4.yml
DOZZLE_COMPOSE=-f ./tools/dozzle/docker-compose.dozzle.yml
RUI_COMPOSE=-f ./tools/redisinsight/docker-compose.redisinsight.yml
COMPOSES=$(MAIN_COMPOSE) $(PGADMIN_COMPOSE) $(DOZZLE_COMPOSE) $(RUI_COMPOSE)

export PYTHONUNBUFFERED 1
export PYTHONDONTWRITEBYTECODE 1
export PYTHONFAULTHANDLER 1
export CURRENT_UID
export DJANGO_DEBUG
export MINIO_ACCESS_KEY
export MINIO_SECRET_KEY

export POSTGRES_USER
export POSTGRES_PASSWORD

define SERVERS_JSON


{
	"Servers": {
		"1": {
			"Name": "Main Database",
			"Group": "Servers",
			"Host": "djc_postgres",
			"Port": 5432,
			"MaintenanceDB": "$(POSTGRES_DB)",
			"Username": "$(POSTGRES_USER)",
			"SSLMode": "prefer",
			"PassFile": "/tmp/pgpassfile"
		}
	}
}
endef

export SERVERS_JSON

build:
	docker compose $(MAIN_COMPOSE) --progress plain build

pgadmin:
	rm -f ./tools/pgadmin4/servers.json
	echo "$$SERVERS_JSON" > ./tools/pgadmin4/servers.json
	./tools/docker/create_volumes.sh djc_pgadmin4_data
	docker compose $(COMPOSES) up -d --renew-anon-volumes --force-recreate --build --remove-orphans pgadmin

dozzle:
	docker compose $(COMPOSES) up -d --renew-anon-volumes --force-recreate --build --remove-orphans dozzle

rui:
	docker compose $(COMPOSES) up -d --renew-anon-volumes --force-recreate --build --remove-orphans redisinsight

up:
	./tools/docker/create_volumes.sh  djc_caddy_data djc_caddy_config djc_db_data djc_s3_data
	docker compose $(MAIN_COMPOSE) build
	docker compose $(MAIN_COMPOSE) up -d --renew-anon-volumes --force-recreate --build --remove-orphans

down:
	docker compose $(COMPOSES) down -v

logs:
	docker compose $(MAIN_COMPOSE) logs -f

sh:
	docker exec -it /djc_server /bin/bash

migrations:
	docker exec -it /djc_server server/manage.py makemigrations

migrate:
	docker exec -it /djc_server server/manage.py migrate

static:
	docker exec -it /djc_server server/manage.py collectstatic

su:
	docker exec -it /djc_server server/manage.py createsuperuser

ruff-format:
	poetry run ruff format .

djlint:
	poetry run djlint . --reformat

clean:
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage staticfiles/* dist
	rm -rf profiles/* tools/pgadmin4/home/* tools/redisinsight/home/*
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	touch staticfiles/.gitkeep
	touch profiles/.gitkeep
	touch tools/pgadmin4/home/.gitkeep
	touch tools/redisinsight/home/.gitkeep


install: clean
	poetry config virtualenvs.in-project true --local
	poetry config virtualenvs.options.no-setuptools true --local
	poetry config virtualenvs.options.no-pip true --local
	poetry config installer.max-workers 10 --local
	poetry install
	git config core.hooksPath tools/git-hooks

lint:
	poetry run mypy .
	poetry run ruff check .
	poetry run djlint . --lint
	poetry run ruff format . --check

format: ruff djlint ruff-format

prune: clean
	rm -rf poetry.lock .vscode .venv
	docker volume rm djc_db_data
	docker volume rm djc_s3_data
	git config core.hooksPath .git/hooks

ruff:
	poetry run ruff check --fix .

shell:
	poetry shell --quiet

pre-commit:
	tools/git-hooks/pre-commit

mypy:
	poetry run mypy .
