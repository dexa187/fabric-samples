#!/bin/bash
set -e

## Runs a few invokes against a channel to show transactions moving through.
declare -a CHANNELS=('buttercup-go' 'haunt' 'crisis-uprising' 'containment-apocalyse' 'rage-trilogy' 'chaos-oath');
declare -a USERNAMES=('jeff' 'nate' 'stephen' 'ryan');
CC_NAME="splunk_cc"

if [ -z $1 ]; then
	echo "No transactions per second arg passed, setting to 1 by default"
	TRANSACTIONS_PER_SECOND=1
else
	TRANSACTIONS_PER_SECOND=$1
fi

echo "================= Buttercup Go!!!! ================="
cat << "EOF"
                            _(\_/) 
                          ,((((^`\
                         ((((  (6 \ 
                       ,((((( ,    \
   ,,,_              ,(((((  /"._  ,`,
  ((((\\ ,...       ,((((   /    `-.-'
  )))  ;'    `"'"'""((((   (      
 (((  /            (((      \
  )) |                      |
 ((  |        .       '     |
 ))  \     _ '      `t   ,.')
 (   |   y;- -,-""'"-.\   \/  
 )   / ./  ) /         `\  \
    |./   ( (           / /'
    ||     \\          //'|
    ||      \\       _//'||
    ||       ))     |_/  ||
    \_\     |_/          ||
    `'"                  \_\
EOF

echo "Press [CTRL+C] to stop.."
while :
do
	for (( i = 0; i < $TRANSACTIONS_PER_SECOND; ++i ))
	do	
		if [ $((RANDOM % 2)) == 1 ]; then
			ORG_NAME="buttercup"
			CORE_PEER_ADDRESS=peer0.buttercup.example.com:7051
			CORE_PEER_LOCALMSPID=ButtercupMSP
			CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/buttercup.example.com/peers/peer0.buttercup.example.com/tls/server.crt
			CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/buttercup.example.com/peers/peer0.buttercup.example.com/tls/server.key
			CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/buttercup.example.com/peers/peer0.buttercup.example.com/tls/ca.crt
			CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/buttercup.example.com/users/Admin@buttercup.example.com/msp
		else
			ORG_NAME="popstar"
			CORE_PEER_ADDRESS=peer0.popstar.example.com:7051
			CORE_PEER_LOCALMSPID=PopstarMSP
			CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/popstar.example.com/peers/peer0.popstar.example.com/tls/server.crt
			CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/popstar.example.com/peers/peer0.popstar.example.com/tls/server.key
			CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/popstar.example.com/peers/peer0.popstar.example.com/tls/ca.crt
			CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/popstar.example.com/users/Admin@popstar.example.com/msp
		fi

		user=${USERNAMES[$((RANDOM % 4))]}
		CHANNEL_NAME=${CHANNELS[$((RANDOM % 6))]}
		score=$((RANDOM % 100))
		peer chaincode invoke -o orderer.example.com:7050  \
							  --tls $CORE_PEER_TLS_ENABLED \
							  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  \
							  -C $CHANNEL_NAME -n $CC_NAME \
							  -c '{"Args":["update","'$user'","'$score'","+"]}' 2> /dev/null &

	done

	echo $i" transactions posted."
	sleep 1
done
