export IMAGE_TAG="latest"
export COMPOSE_PROJECT_NAME="buttercup-games"

docker-compose -f docker-compose-cli.yaml \
			  -f docker-compose-couch.yaml \
			  -f docker-compose-kafka.yaml \
			  down \
			  --volumes --remove-orphans