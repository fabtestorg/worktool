#!/bin/bash

#set -x
NODES=(0 2)
CORE_PEER_TLS_ENABLED=true
ORG1_PEER0="127.0.0.1:7051"
ORG1_PEER1="127.0.0.1:8051"
ORG2_PEER0="127.0.0.1:9051"
ORG2_PEER1="127.0.0.1:10051"
ORDERADDRESS="127.0.0.1:7050"

#如果要用到TLS 方式,则不能用IP方式,由于证书里面和域名有关
#应该在 /etc/hosts 里面添加所有的 域名 和 IP 的映射
if [ "$CORE_PEER_TLS_ENABLED" = "true" ]; then
    ORG1_PEER0="peer0.org1.example.com:7051"
    ORG1_PEER1="peer1.org1.example.com:8051"
    ORG2_PEER0="peer0.org2.example.com:9051"
    ORG2_PEER1="peer1.org2.example.com:10051"
    ORDERADDRESS="orderer.example.com:7050"
fi
TEMPID=$3

CHANNEL_NAME="mychannel"
#如果是动态增加channel，请将CHANNEL_NAME的变量设置为"channel1"
CCNAME="mycc"
CCVERSION=$2
CCPATH="github.com/hyperledger/fabric/examples/chaincode/go/example02/cmd"
#CCPATH="github.com/peersafe/factoring/chaincode"
#CCPATH="github.com/peersafe/aiwan/fabric/chaincode"
CCPACKAGE="factor.out"
INITARGS='{"Args":["init","a","100","b","200"]}'
TESTARGS='{"Args":["query","b"]}'
#TESTARGS='{"Args":["invoke","a","b","1"]}'
#TESTARGS='{"Args":["RegisterUser","b","1"]}'
#TESTARGS='{"Args":["DslQuery","trackid","{\"dslSyntax\":\"{\\\"selector\\\":{\\\"sender\\\":\\\"zhengfu0\\\"}}\"}"]}'

ORDERER_CA="$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"
POLICY="OR  ('Org1MSP.peer','Org2MSP.peer')"

BINPATH=$PWD/bin  #set by yourself
BINPATH=$(which peer | xargs dirname)
PEER=$BINPATH/peer
export FABRIC_CFG_PATH=$PWD

echo "=================== NOTICE ==================="
LOCAL_VERSION=$($PEER version | sed -ne 's/ Version: //p'| head -1)
echo "============Local ENV Version $LOCAL_VERSION============"
echo "============BINPATH=$BINPATH============"
echo "==============================================="
if [[ "$0" =~ "gene" ]]; then
    return
fi
setGlobals () {
    if [ $1 -eq 0 -o $1 -eq 1 ] ; then
    CORE_PEER_LOCALMSPID="Org1MSP"
    CORE_PEER_TLS_CERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/server.key
    CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
        if [ $1 -eq 0 ]; then
            CORE_PEER_ADDRESS=$ORG1_PEER0
        else
            CORE_PEER_ADDRESS=$ORG1_PEER1
        fi
    else
    CORE_PEER_LOCALMSPID="Org2MSP"
    CORE_PEER_TLS_CERT_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.crt
    CORE_PEER_TLS_KEY_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/server.key
    CORE_PEER_TLS_ROOTCERT_FILE=$PWD/crypto-config/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
        if [ $1 -eq 2 ]; then
            CORE_PEER_ADDRESS=$ORG2_PEER0
        else
            CORE_PEER_ADDRESS=$ORG2_PEER1
        fi
    fi
    export CORE_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_TLS_CERT_FILE
    export CORE_PEER_TLS_KEY_FILE
    export CORE_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_LOCALMSPID
    export CORE_PEER_TLS_ENABLED
    export CORE_PEER_MSPCONFIGPATH
    export CORE_PEER_ADDRESS
    env | grep CORE
}

1_SetConfig (){
    echo "*******************creat channel****************************"
	if [ -f "$PEER" ]; then
            echo "Using Peer -> $PEER"
	else
	    echo "miss peer"
        exit 1
	fi

    setGlobals 0
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        $PEER channel create -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx
    else
        $PEER channel create -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
       # $PEER channel create -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/$CHANNEL_NAME.tx --cafile $ORDERER_CA
    fi

    echo "*******************all peer join channel*************************"

    for ch in ${NODES[*]}; do
        setGlobals $ch
        $PEER channel join -b $CHANNEL_NAME.block
        echo "===================== PEER$ch joined on the channel \"$CHANNEL_NAME\" ===================== "
        sleep 2
        echo
    done
    echo "*****************org1 and org2  update anchorPeer**************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
            $PEER channel update -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx
        else
            $PEER channel update -o $ORDERADDRESS -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
        fi
    done
}

2_Deploy () {
    if [ "$CCVERSION" == "" ]; then
        echo "***********2_Deploy error eg: ./deployCC.sh 2 1.0**************"
        exit 1
    fi

	if [ -f "$PEER" ]; then
            echo "Using Peer -> $PEER"
	else
	    echo "miss peer"
        exit 1
	fi

    echo "************************creat  chaincode package******************"
    setGlobals 0
    $PEER chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

    echo "******************all peers install chaincode by package method***********"
    for ch in ${NODES[*]}; do
       setGlobals $ch
        $PEER chaincode install $CCPACKAGE
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done

#    # from code
#    echo "all peers install chaincode by path method"
#    for ch in 0; do
#        setGlobals $ch
#        $PEER chaincode install -n $CCNAME -v $CCVERSION -p $CCPATH
#        echo "===================== PEER$ch install ===================== "
#        sleep 2
#        echo
#    done
#
#    echo "*******************instantiate chaincode only need one org*********************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
            $PEER chaincode instantiate -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        else
           $PEER chaincode instantiate -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        fi
        echo "===================== PEER$ch instantiate ===================== "
    done
    echo "***************test is chaincode depoly success!********************"
    #$PEER chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
}

3_Upgrade () {
    echo "**********************creat  chaincode package*******************"
    if [ "$CCVERSION" == "" ]; then
        echo "3_Upgrade error eg: ./deployCC.sh 3 1.1"
        exit 1
    fi

	if [ -f "$PEER" ]; then
            echo "Using Peer -> $PEER"
	else
	    echo "miss peer"
        exit 1
	fi
    setGlobals 0
    $PEER chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE

#    echo "*********************all peers install chaincode by package method******************"
#    for ch in 0; do
#        setGlobals $ch
#        $PEER chaincode install $CCPACKAGE
#        echo "===================== PEER$ch install ===================== "
#        sleep 2
#        echo
#    done
    # from code
    echo "all peers install chaincode by path method"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        $PEER chaincode install -n $CCNAME -v $CCVERSION -p $CCPATH
        echo "===================== PEER$ch install ===================== "
        sleep 2
        echo
    done

    echo "*********************upgrade chaincode ******************"
    for ch in ${NODES[*]}; do
        setGlobals $ch
        if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
            $PEER chaincode upgrade -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        else
           $PEER chaincode upgrade -o $ORDERADDRESS  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n $CCNAME -v $CCVERSION -c $INITARGS -P "$POLICY"
        fi
    done
    echo "test is chaincode depoly success!"
}

4_Test () {
    echo "************************Test Query******************"
    if [ -f "$PEER" ]; then
            echo "Using Peer -> $PEER"
	else
	    echo "miss peer"
        exit 1
	fi
    setGlobals 0
  #  $PEER chaincode query -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
    if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
        $PEER chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS
    else
        $PEER chaincode invoke -o $ORDERADDRESS -C $CHANNEL_NAME -n $CCNAME -c $TESTARGS --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    fi
}

5_MakePackage () {
    echo "************************creat  chaincode package******************"
    if [ -f "$PEER" ]; then
            echo "Using Peer -> $PEER"
	else
	    echo "miss peer"
        exit 1
	fi
    setGlobals 0
    $PEER chaincode package -n $CCNAME -p $CCPATH -v $CCVERSION $CCPACKAGE
}

6_CouchDBSetIndex () {
    echo "*********************CouchDB Set Sort Index****************"
    for ch in 5 6 7 8; do
        echo `curl -i -X POST -H "Content-Type: application/json" -d              \
        "{\"index\":{\"fields\":[{\"data.createTime\":\"asc\"}]},                 \
        \"ddoc\":\"indexCreateTimeSortDoc\",\"name\":\"indexCreateTimeSortDesc\", \
        \"type\":\"json\"}" http://localhost:{$ch}984/$CHANNEL_NAME/_index`
    echo "=====================CoucdDB localhost:'$ch'984 setIndex success! ===================== "
    done
}
7_fetchBlock () {
    #Use orderer's MSP for fetching system channel config block
    echo $1
    if [ "$1" == "testchainid" ]; then
        echo "fetch testchianid"
        CHANNEL_NAME=$1
        CORE_PEER_LOCALMSPID="OrdererMSP"
	    CORE_PEER_TLS_ROOTCERT_FILE=$ORDERER_CA
	    CORE_PEER_MSPCONFIGPATH=$PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp
	    export CORE_PEER_LOCALMSPID
	    export CORE_PEER_TLS_ROOTCERT_FILE
	    export CORE_PEER_MSPCONFIGPATH
    else
        setGlobals 0
    fi
    echo $CHANNEL_NAME
    $PEER channel fetch newest ${CHANNEL_NAME}_block.pb -o $ORDERADDRESS -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
}

echo "#################################################################"
echo "#######    TLS is $CORE_PEER_TLS_ENABLED   ##########"
echo "#################################################################"
if [ $1 -eq 1 ]; then
    1_SetConfig
elif [ $1 -eq 2 ]; then
    2_Deploy
elif [ $1 -eq 3 ]; then
    3_Upgrade
elif [ $1 -eq 4 ]; then
    4_Test
elif [ $1 -eq 5 ]; then
    5_MakePackage
elif [ $1 -eq 6 ]; then
    6_CouchDBSetIndex
elif [ $1 -eq 7 ]; then
    7_fetchBlock $2
else
    echo "Command Error  channel   eg: ./worktool.sh 1"
    echo "Command Error  deploy cc        eg: ./worktool.sh 2 1.0"
    echo "Command Error  upgrade cc      eg: ./worktool.sh 3 1.1"
    echo "Command Error  test cc          eg: ./worktool.sh 4"
    echo "Command Error  only make package   eg: ./worktool.sh 5 1.0"
    echo "Command Error  couchdb set sortIndex   eg: ./worktool.sh 6"
    echo "Command Error  fetch block  eg: ./worktool.sh 7 testchainid"
    exit
fi

