#!/bin/bash
set -x
tmp="cli"
if [ "$1" != "" ]; then
	tmp=$1
fi
docker-compose -f docker-compose-$tmp.yaml down
docker ps -a | grep dev | awk '{print $1}' | xargs docker rm -f 
docker images |grep "^dev\-peer"|awk '{print $3}'|xargs docker rmi -f
rm -rf peer_data
