#!/bin/bash
set -x
tmp=$1
: ${tmp:="cli"}
if [ "$tmp" == "cli" ]; then
    docker-compose -f docker-compose-cli.yaml up -d
elif [ "$tmp" == "kfk" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  up -d
elif [ "$tmp" == "raft" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  up -d
else
    echo  "unknown type $1  cli, kfk, raft"
fi
