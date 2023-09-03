#!/bin/bash -x

set -o errexit
set -o nounset
set -o pipefail

bash -c /app/docker/entrypoint.sh

celery -A djangoc beat -l INFO -S django_celery_beat.schedulers:DatabaseScheduler
