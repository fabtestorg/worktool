#!/bin/bash

#set -x

echo '这里面生成的证书 configtx.yaml  Rule: "OR('Org1MSP.member')"'
echo 'ca 默认签名证书时间为1年改，需要挂载配置文件修改'
rm -rf crypto-config
rm -rf $PWD/cadata
./stop.sh
./start.sh
sleep 2

TOOL=$GOPATH/src/github.com/hyperledger/fabric-ca/bin/fabric-ca-client
SEC=password
ORGADMIN=$PWD/cadata/orgadmin

gen (){
    TYPE=$1
    NAME=$2
    USER=$PWD/cadata/$ORGNAME/$NAME
    ORGNAME=$3
    CAADMIN=$PWD/cadata/$ORGNAME/Admin@$ORGNAME
    SERVER=$4
    AFFI=$5

    echo "************$CAADMIN 管理员登录********************"
    if [ ! -d "$CAADMIN" ]; then
         FABRIC_CA_CLIENT_HOME=$CAADMIN $TOOL enroll -u http://Admin@$ORGNAME:adminpw@$SERVER -d=true
    else
        echo "*********$CAADMIN 已存在******"
    fi
    if [ "$TYPE" == "orderer" ]; then
        ORGPATH=$PWD/crypto-config/ordererOrganizations/$ORGNAME
        ORGUSER=$ORGPATH/orderers/$NAME
    else
        ORGPATH=$PWD/crypto-config/peerOrganizations/$ORGNAME
        ORGUSER=$ORGPATH/peers/$NAME
    fi
    echo "type=$TYPE,name=$NAME,user=$USER,orgname=$ORGNAME,orguser=$ORGUSER,server=$SERVER"
    echo "#注册$NAME"
    FABRIC_CA_CLIENT_HOME=$CAADMIN $TOOL register --id.name $NAME --id.type $TYPE --id.secret=$SEC --id.attrs 'role='$TYPE':ecert'
    echo "#登记$NAME"
    FABRIC_CA_CLIENT_HOME=$USER $TOOL enroll -u http://$NAME:$SEC@$SERVER --csr.hosts $NAME,$TYPE

    echo "*************生成crypto-config***************"
    echo "**************生成$ORGNAME msp***********"
    mkdir -p $ORGPATH/msp/admincerts/
    mkdir -p $ORGPATH/msp/cacerts/
    mkdir -p $ORGPATH/msp/tlscacerts/

    cp $CAADMIN/msp/signcerts/cert.pem $ORGPATH/msp/admincerts/Admin@$ORGNAME-cert.pem
    cp $CAADMIN/msp/cacerts/*.pem $ORGPATH/msp/cacerts/ca.$ORGNAME-cert.pem
    cp $CAADMIN/msp/cacerts/*.pem $ORGPATH/msp/tlscacerts/tlsca.$ORGNAME-cert.pem

    echo "**************生成$ORGNAME users***********"
    mkdir -p $ORGPATH/users/Admin@$ORGNAME
    cp -r $ORGPATH/msp $ORGPATH/users/Admin@$ORGNAME/
    cp -r $CAADMIN/msp/keystore $ORGPATH/users/Admin@$ORGNAME/msp/
    mkdir -p $ORGPATH/users/Admin@$ORGNAME/msp/signcerts
    cp -r $ORGPATH/users/Admin@$ORGNAME/msp/admincerts/*  $ORGPATH/users/Admin@$ORGNAME/msp/signcerts/

    echo "**************生成$NAME 目录***********"
    mkdir -p $ORGUSER/msp/signcerts
    cp -r $ORGPATH/msp/ $ORGUSER/
    cp $USER/msp/signcerts/cert.pem $ORGUSER/msp/signcerts/$NAME-cert.pem
    cp -r $USER/msp/keystore/ $ORGUSER/msp/

    echo "**************生成$ORGNAME Admin tls目录***********"
    mkdir -p $ORGPATH/users/Admin@$ORGNAME/tls
    mkdir -p $ORGUSER/tls
    echo "**************生成users tls目录***********"
    cp $CAADMIN/msp/cacerts/*.pem $ORGPATH/users/Admin@$ORGNAME/tls/ca.crt
    cp $CAADMIN/msp/signcerts/*.pem $ORGPATH/users/Admin@$ORGNAME/tls/client.crt
    cp $CAADMIN/msp/keystore/*_sk $ORGPATH/users/Admin@$ORGNAME/tls/client.key

    echo "**************生成$NAME tls目录****************"
    cp $ORGUSER/msp/cacerts/*.pem $ORGUSER/tls/ca.crt
    cp $ORGUSER/msp/signcerts/*.pem $ORGUSER/tls/server.crt
    cp $ORGUSER/msp/keystore/*_sk $ORGUSER/tls/server.key
    echo "**************FINISH****************"
}

echo "************开始生成用户************"
gen orderer orderer.example.com example.com localhost:7055 com.example
gen orderer orderer2.example.com example.com localhost:7055 com.example
gen orderer orderer3.example.com example.com localhost:7055 com.example
gen peer peer0.org1.example.com org1.example.com localhost:7056 com.example.org1
gen peer peer1.org1.example.com org1.example.com localhost:7056 com.example.org1