# Splunk for Hyperledger Fabric - Buttercup Games

This is a demo environment to show what's possible with the integration between Splunk and Hyperledger Fabric. To start the environment, first ensure that the Hyperledger Fabric binaries and Docker images are installed:

https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html

From there, you can simply run `./start.sh` in this directory which will spin up all the necessary containers in your local docker environment. 

Splunk will also be installed and accessible at `http://localhost:18000`. The username and password will be `admin / changeme`. Splunk may take up to a minute to start up because it requires downloading the Hyperledger App, you can watch the progress using `docker logs -f splunk.example.com`.

In order to initialize the Hyperledger Fabric network, exec into the docker CLI container (`docker exec -it cli /bin/bash`) and run the following commands:

```
cd scripts
./channel-setup.sh
./random-txns.sh
```

The `channel-setup.sh` script will initialize a few channels and install chaincode on the peers. `random-txns.sh` will randomly generate 1 transaction per second, this can be increased by passing an argument into the script (i.e. `random-txns.sh 3` will run 3 transactions per second).

In order to shutdown the environment, run `./stop.sh`.