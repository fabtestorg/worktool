#!/bin/bash
set -x
tmp=$1
: ${tmp:="cli"}
if [ "$tmp" == "cli" ]; then
    docker-compose -f docker-compose-cli.yaml down
elif [ "$tmp" == "kfk" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  down
elif [ "$tmp" == "raft" ]; then
    docker-compose -f docker-compose-cli.yaml -f docker-compose-$tmp.yaml  down
else
    echo  "unknown type $1  cli, kfk, raft"
fi
docker ps -a | grep dev | awk '{print $1}' | xargs docker rm -f 
docker images |grep "^dev\-peer"|awk '{print $3}'|xargs docker rmi -f
rm -rf peer_data
