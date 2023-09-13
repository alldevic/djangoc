#!/usr/bin/make

.PHONY: pgadmin up down logs sh migrations migrate static su
.PHONY: black djlint clean install lint format prune ruff shell
.DEFAULT_GOAL := lint

include ./.env

SHELL = /bin/bash

CURRENT_UID := $(shell id -u):$(shell id -g)
MAIN_COMPOSE=-f ./docker/docker-compose.yml
PGADMIN_COMPOSE=-f ./tools/pgadmin4/docker-compose.pgadmin4.yml
COMPOSES=$(MAIN_COMPOSE) $(PGADMIN_COMPOSE)

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

pgadmin:
	rm -f ./tools/pgadmin4/servers.json
	echo "$$SERVERS_JSON" > ./tools/pgadmin4/servers.json
	docker volume create djc_db_data
	docker compose $(COMPOSES) up -d --renew-anon-volumes --force-recreate --build --remove-orphans pgadmin

up:
	docker volume create djc_db_data
	docker volume create djc_s3_data
	docker compose $(MAIN_COMPOSE) build --progress plain
	docker compose $(MAIN_COMPOSE) up -d --renew-anon-volumes --force-recreate --build --remove-orphans

down:
	docker compose $(COMPOSES) down -v

logs:
	docker compose $(COMPOSES) logs -f

sh:
	docker exec -it /djc_back /bin/bash

migrations:
	docker exec -it /djc_back server/manage.py makemigrations

migrate:
	docker exec -it /djc_back server/manage.py migrate

static:
	docker exec -it /djc_back server/manage.py collectstatic

su:
	docker exec -it /djc_back server/manage.py createsuperuser

black:
	poetry run black .

djlint:
	poetry run djlint . --reformat

clean:
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage staticfiles/* .venv dist tools/pgadmin4/home/*
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	touch staticfiles/.gitkeep
	touch tools/pgadmin4/home/.gitkeep

install: clean
	poetry config virtualenvs.in-project true --local
	poetry config virtualenvs.options.no-setuptools true --local
	poetry install
	poetry run pre-commit install

lint: ruff
	poetry run djlint . --lint
	poetry run black . --check

format: ruff djlint black

prune: clean
	rm -rf poetry.lock .vscode
	docker volume rm djc_db_data
	docker volume rm djc_s3_data

ruff:
	poetry run ruff check .

shell:
	poetry shell --quiet
