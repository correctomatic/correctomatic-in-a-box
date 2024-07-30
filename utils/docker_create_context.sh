#! /usr/bin/env bash

# You MUST use the domain defined in the configuration file: docker.domain
# The certificates are generated for that specific domain
REMOTE_DOCKER_HOST=docker.correctomatic.alvaromaceda.es
CONTEXT_NAME=correctomatic_vps
CERTIFICATES_DIR="${HOME}/.correctomatic/certs"

CA_CERT_PATH=$CERTIFICATES_DIR/ca.pem
CLIENT_CERT_PATH=$CERTIFICATES_DIR/cert.pem
CLIENT_KEY_PATH=$CERTIFICATES_DIR/key.pem

if docker context ls --format '{{.Name}}' | grep -q "^${CONTEXT_NAME}$"; then
    echo "Docker context '${CONTEXT_NAME}' already exists. Removing it."
    docker context rm "${CONTEXT_NAME}"
fi

# Create Docker Context
docker context create $CONTEXT_NAME \
    --description "Remote Docker Server" \
    --docker "host=tcp://$REMOTE_DOCKER_HOST:2376,ca=$CA_CERT_PATH,cert=$CLIENT_CERT_PATH,key=$CLIENT_KEY_PATH"
