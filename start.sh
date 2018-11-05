#!/bin/bash
set -x
tmp="cli"
if [ "$1" != "" ]; then
    tmp=$1
fi

rm -rf channel-artifacts/ crypto-config mychannel.block 
./generateArtifacts.sh


docker-compose -f docker-compose-$tmp.yaml  up -d

sleep 1

./worktool.sh 1


