#!/bin/bash

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 volume_name1 [volume_name2 ...]"
    exit 1
fi

for VOLUME_NAME in "$@"; do
    if ! docker volume ls --quiet --filter name=^${VOLUME_NAME}$ | grep -q .; then
        echo "Volume ${VOLUME_NAME} not exist. Creating..."
        docker volume create ${VOLUME_NAME}
    else
        echo "Volume ${VOLUME_NAME} already exist."
    fi
done
