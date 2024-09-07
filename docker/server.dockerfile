FROM docker.io/library/debian:bookworm-20240812-slim

ARG DEBUG=False
ARG APT_ADDITIONAL=

SHELL ["/bin/bash", "-c"]

ENV PYTHONFAULTHANDLER=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONHASHSEED=random \
    PYTHONDONTWRITEBYTECODE=1 \
    DJANGO_DEBUG=${DEBUG} \
    PATH="/app/.venv/bin:/opt/poetry/bin:$PATH" \
    POETRY_HOME=/opt/poetry \
    POETRY_VERSION=1.8.3

WORKDIR /app

RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends --no-install-suggests --no-upgrade \
    python3.11 \
    python3-cleo \
    python3-keyring \
    python3.11-venv \
    wait-for-it \
    $APT_ADDITIONAL \
    && ln -sf /usr/bin/python3.11 /usr/bin/python \
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && python -m venv --system-site-packages $POETRY_HOME \
    && $POETRY_HOME/bin/pip install --no-cache-dir poetry==$POETRY_VERSION \
    && $POETRY_HOME/bin/pip uninstall -y pip setuptools \
    && apt-get remove -y --auto-remove python3.11-venv python3-distutils python3-lib2to3 python3-pip-whl python3-setuptools-whl \
    && apt-get clean \
    && apt-get auto-clean \
    && find /usr/lib/python*/* -name '__pycache__' | xargs rm -r \
    && find $POETRY_HOME -name '__pycache__' | xargs rm -r \
    && rm -rf /var/lib/apt/lists/*


RUN poetry --version \
    && poetry config virtualenvs.in-project true \
    && poetry config virtualenvs.options.no-setuptools true \
    && poetry config virtualenvs.options.no-pip true \
    && poetry config installer.max-workers 10

COPY poetry.lock pyproject.toml ./

RUN adduser --system --group app \
    && mkdir /app/staticfiles \
    && chown -R app:app $HOME

    RUN poetry install --no-ansi --no-interaction --no-root --no-cache --only main \
    && if [[ "$DJANGO_DEBUG" == "TRUE" ]] || [[ "$DJANGO_DEBUG" == "True" ]] || [[ "$DJANGO_DEBUG" == "1" ]]; \
    then \
    poetry install --no-ansi --no-interaction --no-root --no-cache --only dev; \
    fi \
    && find /app/.venv/* -name '__pycache__' | xargs rm -r \
    && find /usr/lib/python*/* -name '__pycache__' | xargs rm -r \
    && rm -rf poetry.lock pyproject.toml /root/.cache  /root/.local

USER app
CMD ["./docker/entrypoint.sh"]
