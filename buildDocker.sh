#!/bin/bash
set -x

cd /opt/gopath/src/github.com/hyperledger/fabric 

make -B peer-docker

