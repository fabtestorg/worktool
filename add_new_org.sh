#!/usr/bin/env bash
set -x
CHANNEL_NAME=$2
: ${CHANNEL_NAME:="mychannel"}
echo $CHANNEL_NAME

CONFIGTXLATOR=127.0.0.1:7059
ORDERER1_ADDRESS=127.0.0.1:7050
ORDERER1_MSPPATH=$PWD/crypto-config/ordererOrganizations/example.com/msp
ORDERER1_ADMIN_MSP=$PWD/crypto-config/ordererOrganizations/example.com/users/Admin@example.com/msp
ORG0_MSGCONFIGPATH=$PWD/crypto-config/peerOrganizations/org0.example.com/users/Admin@org0.example.com/msp
ORG1_MSGCONFIGPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
ORG3_MSGCONFIGPATH=$PWD/crypto-config/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
ORG4_MSGCONFIGPATH=$PWD/crypto-config/peerOrganizations/org4.example.com/users/Admin@org4.example.com/msp
#PEER0_ORG1_ADDRESS=127.0.0.1:7051
#PEER0_ORG3_ADDRESS=127.0.0.1:7061
#PEER0_ORG4_ADDRESS=127.0.0.1:9061
ORG0_LOCALMSPID="Org0MSP"
ORG1_LOCALMSPID="Org1MSP"
ORG3_LOCALMSPID="Org3MSP"
ORG4_LOCALMSPID="Org4MSP"
ORDERER1_LOCALMSPID="Orderer1MSP"


ORDERER1_MSPPATH=$PWD/crypto-config/ordererOrganizations/ord1.example.com/msp
ORG1_MSPPATH=$PWD/crypto-config/peerOrganizations/org1.example.com/msp

ORDERER3_MSPPATH=$PWD/crypto-config/ordererOrganizations/ord3.example.com/msp
ORG3_MSPPATH=$PWD/crypto-config/peerOrganizations/org3.example.com/msp

ORDERER4_MSPPATH=$PWD/crypto-config/ordererOrganizations/ord4.example.com/msp
ORG4_MSPPATH=$PWD/crypto-config/peerOrganizations/org4.example.com/msp


1_getBlockConfigJson(){
    if [ -d "update-config" ];then
        rm -rf ./update-config/*
    else
        mkdir update-config
    fi

    # fetch block
#    CORE_PEER_LOCALMSPID=$ORG3_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG3_MSGCONFIGPATH CORE_PEER_ADDRESS=$PEER0_ORG3_ADDRESS peer channel fetch config ./update-config/config_block.pb -o $ORDERER1_ADDRESS -c $CHANNEL_NAME
    CORE_PEER_LOCALMSPID=$ORG1_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG1_MSGCONFIGPATH CORE_PEER_ADDRESS=$PEER0_ORG1_ADDRESS peer channel fetch config ./update-config/config_block.pb -o $ORDERER1_ADDRESS -c $CHANNEL_NAME
#    CORE_PEER_LOCALMSPID=$ORG0_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG0_MSGCONFIGPATH peer channel fetch config ./update-config/config_block.pb -o $ORDERER1_ADDRESS -c $CHANNEL_NAME

    # decode block
    curl -X POST --data-binary @./update-config/config_block.pb http://$CONFIGTXLATOR/protolator/decode/common.Block > ./update-config/config_block.json

    # get config json
    jq .data.data[0].payload.data.config ./update-config/config_block.json > ./update-config/config.json
}

2_channgeConfigJson(){
#    cp ./update-config/config.json ./update-config/updated_config.json ; exit
#    cat update-config/config.json |  jq 'del(.channel_group.groups.Application.groups.Org1MSP)' |   jq 'del(.channel_group.groups.Application.groups.Org2MSP)'  > update-config/updated_config.json
    #*******************for peer add***********************
#    # get base64 cert by fabric-base64 tool
    fabric-base64 -P $ORG1_MSPPATH -o ./update-config/peer_cert.json
    jq '. * {"channel_group":{"groups":{"Application":{"groups":{"Org1MSP": .channel_group.groups.Application.groups.Org0MSP}}}}}' ./update-config/config.json  | jq '.channel_group.groups.Application.groups.Org1MSP.policies.Admins.policy.value.identities[0].principal.msp_identifier = "Org1MSP"' | jq '.channel_group.groups.Application.groups.Org1MSP.policies.Readers.policy.value.identities[0].principal.msp_identifier = "Org1MSP"' | jq '.channel_group.groups.Application.groups.Org1MSP.policies.Writers.policy.value.identities[0].principal.msp_identifier = "Org1MSP"' | jq '.channel_group.groups.Application.groups.Org1MSP.values.MSP.value.config.admins[0]= '$(jq '.peer.admincert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org1MSP.values.MSP.value.config.root_certs[0]= '$(jq '.peer.cacert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org1MSP.values.MSP.value.config.tls_root_certs[0]= '$(jq '.peer.tlscert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org1MSP.values.MSP.value.config.name= "Org3MSP"' | jq '.channel_group.groups.Application.groups.Org1MSP.values.AnchorPeers.value.anchor_peers[0].host= "peer0.org1.example.com"' > ./update-config/updated_config.json
#    #for org4
#    fabric-base64 -P $ORG4_MSPPATH -o ./update-config/peer_cert.json
#    jq '. * {"channel_group":{"groups":{"Application":{"groups":{"Org4MSP": .channel_group.groups.Application.groups.Org3MSP}}}}}' ./update-config/config.json  | jq '.channel_group.groups.Application.groups.Org4MSP.policies.Admins.policy.value.identities[0].principal.msp_identifier = "Org4MSP"' | jq '.channel_group.groups.Application.groups.Org4MSP.policies.Readers.policy.value.identities[0].principal.msp_identifier = "Org4MSP"' | jq '.channel_group.groups.Application.groups.Org4MSP.policies.Writers.policy.value.identities[0].principal.msp_identifier = "Org4MSP"' | jq '.channel_group.groups.Application.groups.Org4MSP.values.MSP.value.config.admins[0]= '$(jq '.peer.admincert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org4MSP.values.MSP.value.config.root_certs[0]= '$(jq '.peer.cacert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org4MSP.values.MSP.value.config.tls_root_certs[0]= '$(jq '.peer.tlscert' ./update-config/peer_cert.json)'' | jq '.channel_group.groups.Application.groups.Org4MSP.values.MSP.value.config.name= "Org4MSP"' | jq '.channel_group.groups.Application.groups.Org4MSP.values.AnchorPeers.value.anchor_peers[0].host= "peer0.org4.example.com"' > ./update-config/updated_config.json
#    #*************************for order add************************
#    # get base64 cert by fabric-base64 tool
#    fabric-base64 -O $ORDERER3_MSPPATH -o ./update-config/orderer_cert.json
#    # copy Ord3 base Ord1
#    jq '. * {"channel_group":{"groups":{"Orderer":{"groups":{"OrdererOrg3": .channel_group.groups.Orderer.groups.OrdererOrg1}}}}}'  ./update-config/config.json  | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.policies.Admins.policy.value.identities[0].principal.msp_identifier = "Orderer3MSP"' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.policies.Readers.policy.value.identities[0].principal.msp_identifier = "Orderer3MSP"' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.policies.Writers.policy.value.identities[0].principal.msp_identifier = "Orderer3MSP"' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.values.MSP.value.config.admins[0]= '$(jq '.orderer.admincert' ./update-config/orderer_cert.json)'' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.values.MSP.value.config.root_certs[0]= '$(jq '.orderer.cacert' ./update-config/orderer_cert.json)'' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.values.MSP.value.config.tls_root_certs[0]= '$(jq '.orderer.tlscert' ./update-config/orderer_cert.json)'' | jq '.channel_group.groups.Orderer.groups.OrdererOrg3.values.MSP.value.config.name= "Orderer3MSP"' | jq '.channel_group.values.OrdererAddresses.value.addresses[2]= "orderer.ord3.example.com:7050"' > ./update-config/updated_config.json
}

3_setNewConfigJson(){
    # encode config
    curl -X POST --data-binary @./update-config/config.json http://$CONFIGTXLATOR/protolator/encode/common.Config > ./update-config/config.pb
    curl -X POST --data-binary @./update-config/updated_config.json http://$CONFIGTXLATOR/protolator/encode/common.Config > ./update-config/updated_config.pb

    # compute update
    curl -s -X POST -F channel=mychannel -F original=@./update-config/config.pb -F updated=@./update-config/updated_config.pb http://$CONFIGTXLATOR/configtxlator/compute/update-from-configs > ./update-config/config_update.pb

    # convert to json
    curl -X POST --data-binary @./update-config/config_update.pb http://$CONFIGTXLATOR/protolator/decode/common.ConfigUpdate > ./update-config/config_update.json

    # package envelope
    echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat ./update-config/config_update.json)'}}}' | jq . > ./update-config/config_update_in_envelope.json

    # encode envelope json to pb
    curl -X POST --data-binary @./update-config/config_update_in_envelope.json http://$CONFIGTXLATOR/protolator/encode/common.Envelope > ./update-config/config_update_in_envelope.pb

#    CORE_PEER_LOCALMSPID=$ORG1_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG1_MSGCONFIGPATH CORE_PEER_ADDRESS=$PEER0_ORG1_ADDRESS peer channel update -f ./update-config/config_update_in_envelope.pb -c mychannel -o $ORDERER1_ADDRESS
    CORE_PEER_LOCALMSPID=$ORG0_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG0_MSGCONFIGPATH peer channel update -f ./update-config/config_update_in_envelope.pb -c mychannel -o $ORDERER1_ADDRESS
#    CORE_PEER_LOCALMSPID=$ORG3_LOCALMSPID CORE_PEER_MSPCONFIGPATH=$ORG3_MSGCONFIGPATH CORE_PEER_ADDRESS=$PEER0_ORG3_ADDRESS peer channel update -f ./update-config/config_update_in_envelope.pb -c mychannel -o $ORDERER1_ADDRESS
}

if [ $1 -eq 1 ]; then
    1_getBlockConfigJson
elif [ $1 -eq 2 ]; then
    2_channgeConfigJson
elif [ $1 -eq 3 ]; then
    3_setNewConfigJson
else 
    echo "Command Error not exist $1"
    exit
fi
