#!/bin/bash -x

set -o errexit
set -o pipefail

function postgres_ready() {
    python3 <<END
import sys
import psycopg
from os import environ
def get_env(key, default=None):
    val = environ.get(key, default)
    if val == 'True':
        val = True
    elif val == 'False':
        val = False
    return val
try:
    dbname = get_env('POSTGRES_DB')
    user = get_env('POSTGRES_USER')
    password = get_env('POSTGRES_PASSWORD')
    host = get_env('POSTGRES_HOST')
    port = 5432
    conn = psycopg.connect(dbname=dbname, user=user, password=password, host=host, port=port)
except psycopg.OperationalError:
    sys.exit(-1)
sys.exit(0)
END
}

until postgres_ready; do
    echo >&2 "Postgres is unavailable - sleeping"
    sleep 1
done

echo >&2 "Postgres is up - continuing..."

echo >&2 "Migrating..."
python3 src/manage.py migrate

echo >&2 "Collect static..."
python3 src/manage.py collectstatic --noinput

if [[ ${DJANGO_DEBUG} == 'TRUE' ]] || [[ ${DJANGO_DEBUG} == 'True' ]] || [[ ${DJANGO_DEBUG} == '1' ]]; then
    echo >&2 "Starting development server..."
    exec python3 src/manage.py runserver 0.0.0.0:8000
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
