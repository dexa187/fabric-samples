'use strict';

const fs = require('fs');
const express = require('express');
const request = require('request');
const hfc = require('fabric-client');
const app = express();

// Constants
const SPLUNK_HEC_URL = process.env.SPLUNK_HEC_URL;
const SPLUNK_HEC_TOKEN = process.env.SPLUNK_HEC_TOKEN;
const FABRIC_PEER = process.env.FABRIC_PEER;
const FABRIC_CHANNEL_LIST = process.env.FABRIC_CHANNEL_LIST.split(",");
var client = hfc.loadFromConfig('network.yaml');

// Take this out if you go to prod!!!
var pkey = fs.readdirSync('crypto/peerOrganizations/pony.example.com/users/Admin@pony.example.com/msp/keystore')[0];
client.setAdminSigningIdentity(
	fs.readFileSync('crypto/peerOrganizations/pony.example.com/users/Admin@pony.example.com/msp/keystore/' + pkey, 'utf8'),
	fs.readFileSync('crypto/peerOrganizations/pony.example.com/users/Admin@pony.example.com/msp/signcerts/Admin@pony.example.com-cert.pem', 'utf8'),
	'PonyMSP'
);

function postToSplunk(event, sourcetype) {
	request({
		uri: SPLUNK_HEC_URL,
		method: "POST",
		json: {
			"index": "hyperledger_logs",
			"sourcetype": sourcetype,
			"event": event
		},
		headers: {
			"Authorization": "Splunk " + SPLUNK_HEC_TOKEN
		},
		strictSSL: false
	}, function (err, resp, body) {
		if (err) { 
			console.log(err);
			console.log(resp);
			console.log(body); 
		}
	});
	console.log("Posted " + sourcetype + " to splunk.")
}

for (i = 0; i < FABRIC_CHANNEL_LIST.length; i++) {
	eh = client.getChannel(FABRIC_CHANNEL_LIST[i]).newChannelEventHub(FABRIC_PEER);
	eh.registerBlockEvent(
		(block) => {
			postToSplunk(block, "ledger-block");

			// Message types are defined here:
			// https://github.com/hyperledger/fabric-sdk-node/blob/release-1.4/fabric-client/lib/protos/common/common.proto
			for (index = 0; index < block.data.data.length; index++) { 
				let msg = block.data.data[index];
				postToSplunk(msg, msg.payload.header.channel_header.typeString)
			} 
		},
		(error) => { console.log('Failed to receive the tx event ::' + error); },
		{ 'startBlock': 1 }
	)
	eh.connect({ 'full_block': true });
}

app.get('/healthcheck', (req, res) => {
	res.send('ok!')
});

const HOST = "0.0.0.0";
const PORT = 8080;
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);