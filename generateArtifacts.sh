#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#


#set -e

CHANNEL_NAME=$1
: ${CHANNEL_NAME:="mychannel"}
CONSENSUS_TYPE=$2
: ${CONSENSUS_TYPE:="raft"}

echo $CHANNEL_NAME
echo $CONSENSUS_TYPE

export FABRIC_ROOT=$PWD
export FABRIC_CFG_PATH=$PWD
echo

BINPATH=$PWD/bin
#BINPATH=$PWD/gm-bin
CRYPTOGEN=$BINPATH/cryptogen
CONFIGTXGEN=$BINPATH/configtxgen

## Generates Org certs using cryptogen tool
function generateCerts (){

	if [ -f "$CRYPTOGEN" ]; then
            echo "Using cryptogen -> $CRYPTOGEN"
	else
	    echo "miss cryptogen"
        exit 1
	fi

	echo
	echo "##########################################################"
	echo "##### Generate certificates using cryptogen tool #########"
	echo "##########################################################"
	$CRYPTOGEN generate --config=./crypto-config.yaml
#        echo "##########################################################"
#        $CRYPTOGEN showtemplate 
#        echo "##########################################################"
#        $CRYPTOGEN version
#	echo
}

## Generate orderer genesis block , channel configuration transaction and anchor peer update transactions
function generateChannelArtifacts() {
    mkdir -p channel-artifacts

	if [ -f "$CONFIGTXGEN" ]; then
            echo "Using configtxgen -> $CONFIGTXGEN"
	else
	    echo "miss configtxgen"
	fi

	echo "##########################################################"
	echo "#########  Generating Orderer Genesis block ##############"
	echo "##########################################################"
	# Note: For some unknown reason (at least for now) the block file can't be
	# named orderer.genesis.block or the orderer will fail to launch!
    if [ "$CONSENSUS_TYPE" == "solo" ]; then
        $CONFIGTXGEN  -profile ThreeOrgsOrdererGenesis -channelID textchainid -outputBlock ./channel-artifacts/genesis.block
    elif [ "$CONSENSUS_TYPE" == "kafka" ]; then
        $CONFIGTXGEN  -profile SampleDevModeKafka -channelID textchainid -outputBlock ./channel-artifacts/genesis.block
    elif [ "$CONSENSUS_TYPE" == "raft" ]; then
        $CONFIGTXGEN  -profile SampleMultiNodeEtcdRaft -channelID textchainid -outputBlock ./channel-artifacts/genesis.block
    fi
	echo
	echo "#################################################################"
	echo "### Generating channel configuration transaction 'channel.tx' ###"
	echo "#################################################################"
	$CONFIGTXGEN -profile ThreeOrgsChannel -outputCreateChannelTx ./channel-artifacts/$CHANNEL_NAME.tx -channelID $CHANNEL_NAME

	echo
	echo "#################################################################"
	echo "#######    Generating anchor peer update for Org1MSP   ##########"
	echo "#################################################################"
	$CONFIGTXGEN -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP

	echo
	echo "#################################################################"
	echo "#######    Generating anchor peer update for Org2MSP   ##########"
	echo "#################################################################"
	$CONFIGTXGEN -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
	$CONFIGTXGEN -profile ThreeOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org3MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org3MSP

	echo
}

#generateCerts
generateChannelArtifacts

