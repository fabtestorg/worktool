#!/usr/bin/env bash

set -x

cd /opt/gopath/src/github.com/hyperledger/fabric/common/tools/cryptogen
go build
mv cryptogen /opt/gopath/src/github.com/peersafe/worktool/bin

cd /opt/gopath/src/github.com/hyperledger/fabric/common/tools/configtxgen
go build
mv configtxgen /opt/gopath/src/github.com/peersafe/worktool/bin

cd /opt/gopath/src/github.com/hyperledger/fabric/common/tools/configtxlator
go build
mv configtxlator /opt/gopath/src/github.com/peersafe/worktool/bin

cd /opt/gopath/src/github.com/hyperledger/fabric/peer
go build
mv peer /opt/gopath/src/github.com/peersafe/worktool/bin