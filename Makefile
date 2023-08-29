.PHONY: black clean install lint prune ruff shell
.DEFAULT_GOAL := lint
CURRENT_UID := $(shell id -u):$(shell id -g)

export PYTHONUNBUFFERED 1
export PYTHONDONTWRITEBYTECODE 1
export CURRENT_UID

up:
	docker volume create dj_db_data
	docker compose up -d --renew-anon-volumes --force-recreate --build --remove-orphans

down:
	docker compose down

logs:
	docker compose logs -f

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
	rm -rf .mypy_cache .pytest_cache .ruff_cache htmlcov .coverage
	find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete

install: clean
	poetry config virtualenvs.in-project true --local
	poetry config virtualenvs.options.no-setuptools true --local
	poetry install
	poetry run pre-commit install

lint: ruff black

prune: clean
	rm -rf .venv poetry.lock .vscode static/* media/*
	touch static/.gitkeep
	touch media/.gitkeep

ruff:
	poetry run ruff check .

shell:
	poetry shell --quiet
