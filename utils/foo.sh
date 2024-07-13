#!/bin/bash

# Variables
REMOTE_DOCKER_HOST=<remote-docker-server>
CA_CERT_PATH=<path-to-ca.pem>
CLIENT_CERT_PATH=<path-to-cert.pem>
CLIENT_KEY_PATH=<path-to-key.pem>
CONTEXT_NAME=my-remote-docker

# Create Docker Context
docker context create $CONTEXT_NAME \
    --description "Remote Docker Server" \
    --docker "host=tcp://$REMOTE_DOCKER_HOST:2376,ca=$CA_CERT_PATH,cert=$CLIENT_CERT_PATH,key=$CLIENT_KEY_PATH"

# Use the Docker Context
docker context use $CONTEXT_NAME

# Verify Connection
docker info
