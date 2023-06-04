FROM ubuntu:lunar

ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends --no-install-suggests --no-upgrade \
    python3.11 \
    python3-poetry \
    ca-certificates \
    && ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && rm -rf /var/lib/apt/lists/*  /root/.cache/* \
    && find /usr/lib/python*/* -name '__pycache__' | xargs rm -r \
    && python --version \
    && poetry --version \
    && poetry config virtualenvs.in-project true \
    && poetry config virtualenvs.options.no-setuptools true \
    && poetry config virtualenvs.options.no-pip true \
    && poetry config installer.max-workers 10

COPY poetry.lock pyproject.toml ./

RUN poetry install --no-ansi --no-interaction --no-root --no-cache --only main \
    && find /app/.venv/* -name '__pycache__' | xargs rm -r \
    && find /usr/lib/python*/* -name '__pycache__' | xargs rm -r \
    && rm -rf poetry.lock pyproject.toml /root/.cache

ENV PATH="/app/.venv/bin:$PATH"
