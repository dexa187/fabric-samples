set -ex

export FABRIC_CFG_PATH=${PWD}/scripts/config
export IMAGE_TAG="latest"
export CONSENSUS_TYPE="kafka"
export COMPOSE_PROJECT_NAME="buttercup-games"
export PATH=${PWD}/../bin:${PWD}:$PATH

if [ -d "crypto" ]; then
	rm -Rf crypto
fi
cryptogen generate --config=./scripts/config/crypto-config.yaml --output "crypto"

configtxgen -profile SampleDevModeKafka -channelID byfn-sys-channel -outputBlock ./channel-artifacts/genesis.block

docker-compose -f docker-compose-cli.yaml \
			   -f docker-compose-kafka.yaml \
			   -f docker-compose-couch.yaml \
			   -f docker-compose-splunk.yaml \
			   -f docker-compose-splunk-couch.yaml \
			   -f docker-compose-splunk-kafka.yaml up -d

echo "Waiting 15 seconds for containers to start..."
sleep 15