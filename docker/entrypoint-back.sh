#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

bash -c /app/docker/entrypoint.sh

echo >&2 "Migrating..."
python3 /app/server/manage.py migrate

echo >&2 "Init MiniO buckets..."
python3 /app/server/manage.py init_minio

echo >&2 "Collect static..."
python3 /app/server/manage.py collectstatic --noinput

if [[ ${DJANGO_DEBUG} = @(True|TRUE|1) ]]; then
    if [[ ${DJANGO_USE_DEBUGPY} = @(True|TRUE|1) ]]; then
        echo >&2 "Starting debugpy server..."
        exec python3 /app/server/manage.py rundebugserver 0.0.0.0:8000 --nostatic
    else
        echo >&2 "Starting development server..."
        exec python3 /app/server/manage.py runserver 0.0.0.0:8000 --nostatic
    fi
else
    echo >&2 "Starting Gunicorn..."
    exec gunicorn server.config.wsgi \
        --chdir /app/server/ \
        -k eventlet \
        --access-logfile - \
        --name config \
        --bind 0.0.0.0:8000 \
        --max-requests 100 \
        --workers=2
fi
