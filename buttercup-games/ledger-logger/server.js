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
var client = hfc.loadFromConfig('network.yaml');

// DIRTY HACK ALERT: Take this out if you go to prod!!!
var pkey = fs.readdirSync('crypto/peerOrganizations/buttercup.example.com/users/Admin@buttercup.example.com/msp/keystore')[0];
client.setAdminSigningIdentity(
	fs.readFileSync('crypto/peerOrganizations/buttercup.example.com/users/Admin@buttercup.example.com/msp/keystore/' + pkey, 'utf8'),
	fs.readFileSync('crypto/peerOrganizations/buttercup.example.com/users/Admin@buttercup.example.com/msp/signcerts/Admin@buttercup.example.com-cert.pem', 'utf8'),
	'ButtercupMSP'
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

async function asyncEHWrapper(eh) {
	eh.connect({ 'full_block': true });
}

app.get('/channels/:channel', (req, res) => {
	let eh = client.getChannel(req.params["channel"]).newChannelEventHub(FABRIC_PEER);
	eh.registerBlockEvent(
		(block) => {
			postToSplunk(block, "ledger-block");

			// Message types are defined here:
			// https://github.com/hyperledger/fabric-sdk-node/blob/release-1.4/fabric-client/lib/protos/common/common.proto
			for (let index = 0; index < block.data.data.length; index++) {
				let msg = block.data.data[index];
				postToSplunk(msg, msg.payload.header.channel_header.typeString)
			} 
		},
		(error) => { console.log('Failed to receive the tx event ::' + error); },
		{ 'startBlock': 1 }
	)
	asyncEHWrapper(eh);

	res.send("Connecting to " + req.params["channel"] + " on "  + FABRIC_PEER)
});

app.get('/healthcheck', (req, res) => {
	res.send('ok!')
});

const HOST = "0.0.0.0";
const PORT = 8080;
app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);