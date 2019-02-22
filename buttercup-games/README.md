# Splunk for Hyperledger Fabric - Buttercup Games

This is a demo environment to show what's possible with the integration between Splunk and Hyperledger Fabric. To start the environment, first ensure that the Hyperledger Fabric binaries and Docker images are installed:

https://hyperledger-fabric.readthedocs.io/en/release-1.4/install.html

From there, you can simply run `./start.sh` in this directory which will spin up all the necessary containers in your local docker environment. 

In order to initialize the Hyperledger Fabric network, exec into the docker CLI container (`docker exec -it cli /bin/bash`) and run the following commands:

```
cd scripts
./channel-setup.sh
./random-txns.sh
```

The `channel-setup.sh` script will initialize a few channels and install chaincode on the peers. `random-txns.sh` will randomly generate 1 transaction per second, this can be increased by passing an argument into the script (i.e. `random-txns.sh 3` will run 3 transactions per second).

Once the channels are set up and transactions are flowing, you can log into Splunk which will be installed and accessible at `http://localhost:18000`. The username and password will be `admin / changeme`. Splunk may take up to a minute to start up because it requires downloading the Hyperledger App, you can watch the progress using `docker logs -f splunk.example.com`.

In order to shutdown the environment, run `./stop.sh`.

Once logged into Splunk, you can view the Hyperledger Fabric dashboards inside the Hyperledger Splunk application.

<img src="https://www.splunk.com/content/dam/splunk-blogs/images/2019/02/hyperledger-network-architecture.png" alt="Network Architecture and Channels" width="100%" />

With the Network Architecture and Channels dashboard, you can see at a glance the number of orderers, peers, and channels in your Hyperledger Fabric network.

<img src="https://www.splunk.com/content/dam/splunk-blogs/images/2019/02/hyperledger-infrastructure-monitoring-down.png" alt="Infrastructure Health and Monitoring" width="100%" />

The Infrastructure Health and Monitoring dashboard will give you an overview of system health from system metrics like CPU, uptime status as well as transaction latency. You can see in real time when transactions are starting to back up or a peer is falling behind on blocks.

<img src="https://www.splunk.com/content/dam/splunk-blogs/images/2019/01/hyperledger-transaction-analytics.png" alt="Transaction Analytics" width="100%" />

Our Transaction Analytics dashboard will give you real time visibility into the transactions being written on each ledger. In this dashboard, we’re blending ledger data sent from the peers with logs and metrics to give a holistic view of the network’s health.
