#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

bash -c /app/docker/entrypoint.sh

echo >&2 "Collect static..."
python3 /app/src/manage.py collectstatic --noinput

if [[ ${DJANGO_DEBUG} == 'TRUE' ]] || [[ ${DJANGO_DEBUG} == 'True' ]] || [[ ${DJANGO_DEBUG} == '1' ]]; then
    echo >&2 "Starting development server..."
    exec python3 /app/src/manage.py rundebugserver 0.0.0.0:8000 --nostatic
else
    echo >&2 "Starting Gunicorn..."
    exec gunicorn src.djangoc.wsgi \
        --chdir /app/src/ \
        -k eventlet \
        --access-logfile - \
        --name djangoc \
        --bind 0.0.0.0:8000 \
        --max-requests 100 \
        --workers=2
fi
