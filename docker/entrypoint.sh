#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

echo >&2 "MiniO waiting..."
wait-for-it \
    --host="minio" \
    --port=9000 \
    --timeout=90 \
    --strict

echo >&2 "PostgreSQL waiting..."
wait-for-it \
    --host="$POSTGRES_HOST" \
    --port=5432 \
    --timeout=90 \
    --strict
echo >&2 "PostgreSQL is up - continuing..."

echo >&2 "Migrating..."
python3 /app/server/manage.py migrate

echo >&2 "Init MiniO buckets..."
python3 /app/server/manage.py init_minio
