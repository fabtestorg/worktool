#!/bin/bash
set -x
tmp="root"
if [ "$1" != "" ]; then
    tmp=$1
fi
docker-compose -f docker-compose-$tmp.yaml  up -d
