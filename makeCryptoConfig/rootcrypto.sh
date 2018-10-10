#!/bin/bash
#set -x
rm -rf crypto-config
TOOL=$GOPATH/src/github.com/hyperledger/fabric-ca/bin/fabric-ca-client
echo '没有中间CA的证书目录'
echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<####orderer######>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'
echo 'orderer机构管理员登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/ordererOrganizations/example.com/admin $TOOL enroll -u http://Admin@example.com:adminpw@localhost:7055 -d=true
echo '#注册example.com 的orderer'

FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/ordererOrganizations/example.com/admin $TOOL register --id.name orderer.example.com --id.type orderer --id.secret=123456 -u http://Admin@example.com:adminpw@localhost:7055
echo '#orderer登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com $TOOL enroll -u http://orderer.example.com:123456@localhost:7055 --csr.hosts orderer.example.com,orderer

echo '#整理example.com 目录结构'
echo '#生成example.com 的msp'
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/msp/admincerts/
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/msp/cacerts/
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/

cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/signcerts/cert.pem $PWD/crypto-config/ordererOrganizations/example.com/msp/admincerts/Admin@example.com-cert.pem
cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/msp/cacerts/ca.example.com-cert.pem
cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem

echo '#生成users/Admin@example.com'
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com
cp -r $PWD/crypto-config/ordererOrganizations/example.com/msp $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/
cp -r $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/keystore $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
cp -r  $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/admincerts  $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp/signcerts

echo '#整理orderer.example.com目录结构'
rm -r $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts
rm -r $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/intermediatecerts
mv $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/cert.pem $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/orderer.example.com-cert.pem
cp -r $PWD/crypto-config/ordererOrganizations/example.com/msp $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/

echo '#tls目录整理'
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls
mkdir -p $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls

cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/ca.crt
cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/signcerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/server.crt
cp $PWD/crypto-config/ordererOrganizations/example.com/admin/msp/keystore/*_sk $PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/tls/server.key

cp $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/cacerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt
cp $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/signcerts/*.pem $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt
cp $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/keystore/*_sk $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key

echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<####org1######>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'

echo 'org1机构管理员登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org1.example.com/admin $TOOL enroll -u http://Admin@org1.example.com:adminpw@localhost:7056 -d=true
echo '#注册org1.example.com 的peer0,peer1,user1'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org1.example.com/admin $TOOL register --id.name peer0.org1.example.com --id.type peer --id.secret=123456 -u http://Admin@org1.example.com:adminpw@localhost:7056
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org1.example.com/admin $TOOL register --id.name peer1.org1.example.com --id.type peer --id.secret=123456 -u http://Admin@org1.example.com:adminpw@localhost:7056
echo '#peer0,peer1登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com $TOOL enroll -u http://peer0.org1.example.com:123456@localhost:7056 --csr.hosts peer0.org1.example.com,peer0
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com $TOOL enroll -u http://peer1.org1.example.com:123456@localhost:7056 --csr.hosts peer1.org1.example.com,peer1

echo '#整理org1.example.com 目录结构'
echo '#生成org1.example.com 的msp'
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/msp/admincerts/
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/msp/cacerts/
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/

cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org1.example.com/msp/admincerts/Admin@org1.example.com-cert.pem
cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/msp/cacerts/ca.org1.example.com-cert.pem
cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/msp/tlscacerts/tlsca.org1.example.com-cert.pem

echo '#生成users/Admin@org1.example.com'
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com
cp -r $PWD/crypto-config/peerOrganizations/org1.example.com/msp $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/
cp -r $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/keystore $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
cp -r  $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/admincerts  $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts

echo '#整理peer0.org1.example.com,peer1.org1.example.com目录结构'
rm -r $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts
rm -r $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/intermediatecerts
mv $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/signcerts/peer0.org1.example.com-cert.pem
cp -r $PWD/crypto-config/peerOrganizations/org1.example.com/msp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/

rm -r $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/cacerts
mv $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/signcerts/peer1.org1.example.com-cert.pem
cp -r $PWD/crypto-config/peerOrganizations/org1.example.com/msp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/

echo '#tls目录整理'
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls
mkdir -p $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls

cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/admin/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/tls/server.key

cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key

cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/server.key

echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<####org2######>>>>>>>>>>>>>>>>>>>>>'
echo '<<<<<<<<<<<<<<<<<<<<<<<<##########>>>>>>>>>>>>>>>>>>>>>'

echo 'org2机构管理员登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org2.example.com/admin $TOOL enroll -u http://Admin@org2.example.com:adminpw@localhost:7057 -d=true
echo '#注册org2.example.com 的peer0,peer1,user1'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org2.example.com/admin $TOOL register --id.name peer0.org2.example.com --id.type peer --id.secret=123456 -u http://Admin@org2.example.com:adminpw@localhost:7057
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org2.example.com/admin $TOOL register --id.name peer1.org2.example.com --id.type peer --id.secret=123456 -u http://Admin@org2.example.com:adminpw@localhost:7057
echo '#peer0,peer1登录'
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com $TOOL enroll -u http://peer0.org2.example.com:123456@localhost:7057 --csr.hosts peer0.org2.example.com,peer0
FABRIC_CA_CLIENT_HOME=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com $TOOL enroll -u http://peer1.org2.example.com:123456@localhost:7057 --csr.hosts peer1.org2.example.com,peer1

echo '#整理org2.example.com 目录结构'
echo '#生成org2.example.com 的msp'
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/msp/admincerts/
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/msp/cacerts/
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/

cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org2.example.com/msp/admincerts/Admin@org2.example.com-cert.pem
cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/msp/cacerts/ca.org2.example.com-cert.pem
cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/msp/tlscacerts/tlsca.org2.example.com-cert.pem

echo '#生成users/Admin@org2.example.com'
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com
cp -r $PWD/crypto-config/peerOrganizations/org2.example.com/msp $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/
cp -r $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/keystore $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
cp -r  $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/admincerts  $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp/signcerts

echo '#整理peer0.org2.example.com,peer1.org2.example.com目录结构'
rm -r $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts
rm -r $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/intermediatecerts
mv $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/signcerts/peer0.org2.example.com-cert.pem
cp -r $PWD/crypto-config/peerOrganizations/org2.example.com/msp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/

rm -r $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/cacerts
rm -r $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/intermediatecerts
mv $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/signcerts/cert.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/signcerts/peer1.org2.example.com-cert.pem
cp -r $PWD/crypto-config/peerOrganizations/org2.example.com/msp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/

echo '#tls目录整理'
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls
mkdir -p $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls

cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/admin/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/tls/server.key

cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key

cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/cacerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/signcerts/*.pem $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.crt
cp $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/msp/keystore/*_sk $PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/server.key


