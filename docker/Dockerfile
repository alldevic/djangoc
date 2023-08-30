FROM ubuntu:23.04

ARG DEBUG=False

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_DEBUG=${DEBUG}

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
    && poetry install --no-ansi --no-interaction --no-root --no-cache --only dev \
    && find /app/.venv/* -name '__pycache__' | xargs rm -r \
    && find /usr/lib/python*/* -name '__pycache__' | xargs rm -r \
    && rm -rf poetry.lock pyproject.toml /root/.cache

ENV PATH="/app/.venv/bin:$PATH"

CMD ["./docker/entrypoint.sh"]
