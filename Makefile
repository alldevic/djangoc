#!/usr/bin/make

.PHONY: black clean install lint prune ruff shell
.DEFAULT_GOAL := lint
CURRENT_UID := $(shell id -u):$(shell id -g)

include .env

export PYTHONUNBUFFERED 1
export PYTHONDONTWRITEBYTECODE 1
export PYTHONFAULTHANDLER 1
export CURRENT_UID
export DJANGO_DEBUG
export MINIO_ACCESS_KEY
export MINIO_SECRET_KEY

up:
	docker volume create dj_db_data
	docker volume create dj_s3_data
	docker compose -f docker/docker-compose.yml build --progress plain
	docker compose -f docker/docker-compose.yml up -d --renew-anon-volumes --force-recreate --build --remove-orphans

down:
	docker compose -f docker/docker-compose.yml down -v

logs:
	docker compose -f docker/docker-compose.yml logs -f

sh:
	docker exec -it /dj_back /bin/bash

migrations:
	docker exec -it /dj_back server/manage.py makemigrations

migrate:
	docker exec -it /dj_back server/manage.py migrate

static:
	docker exec -it /dj_back server/manage.py collectstatic

su:
	docker exec -it /dj_back server/manage.py createsuperuser

black:
	poetry run black .

djlint:
	poetry run djlint . --reformat

clean:
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage staticfiles/* .venv dist
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete
	touch staticfiles/.gitkeep

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
	docker volume rm dj_db_data
	docker volume rm dj_s3_data

ruff:
	poetry run ruff check .

shell:
	poetry shell --quiet
