#!/usr/bin/make

.PHONY: black clean install lint prune ruff shell
.DEFAULT_GOAL := lint
CURRENT_UID := $(shell id -u):$(shell id -g)

include .env

export PYTHONUNBUFFERED 1
export PYTHONDONTWRITEBYTECODE 1
export PYTHONFAULTHANDLER=1
export CURRENT_UID
export DJANGO_DEBUG
up:
	docker volume create dj_db_data
	docker compose -f docker/docker-compose.yml up -d --renew-anon-volumes --force-recreate --build --remove-orphans

down:
	docker compose -f docker/docker-compose.yml down

logs:
	docker compose -f docker/docker-compose.yml logs -f

sh:
	docker exec -it /dj_back /bin/bash

migrations:
	docker exec -it /dj_back src/manage.py makemigrations

migrate:
	docker exec -it /dj_back src/manage.py migrate

static:
	docker exec -it /dj_back src/manage.py collectstatic

su:
	docker exec -it /dj_back src/manage.py createsuperuser

black:
	poetry run black .

clean:
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage staticfiles/*
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	touch staticfiles/.gitkeep

install: clean
	poetry config virtualenvs.in-project true --local
	poetry config virtualenvs.options.no-setuptools true --local
	poetry install
	poetry run pre-commit install

lint: ruff black

prune: clean
	rm -rf .venv poetry.lock .vscode media/*
	touch media/.gitkeep

ruff:
	poetry run ruff check .

shell:
	poetry shell --quiet
