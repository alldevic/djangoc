#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

bash -c /app/docker/entrypoint.sh

celery -A config worker -P eventlet -c 100 -l INFO
