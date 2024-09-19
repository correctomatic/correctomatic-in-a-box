#! /usr/bin/env bash

# Check if the first parameter is provided
if [ -z "$1" ]; then
    echo "Error: No environment or file provided."
    echo "Usage: $0 [PROD|DEV|/path/to/file.yml]"
    exit 1
fi

# If we are in "utils" directory, we need to go one directory up
current_dir=$(basename "$PWD")
if [ "$current_dir" == "utils" ]; then
    UP="../"
fi

PROD_CONFIG_FILE="${UP}inventories/prod/group_vars/all/config.yml"
DEV_CONFIG_FILE="${UP}inventories/dev/group_vars/all/config.yml"
DEFAULT_DOCKER_HOST="dev.registry.correctomatic.org"

case "$1" in
    PROD)
        CONFIG_FILE="$PROD_CONFIG_FILE"
        ENVIRONMENT="prod"
        ;;
    DEV)
        CONFIG_FILE="$DEV_CONFIG_FILE"
        ENVIRONMENT="dev"
        ;;
    *)
        CONFIG_FILE="$1"
        ENVIRONMENT="custom"
        ;;
esac

# Check if yq is installed
if command -v yq &> /dev/null; then
    REMOTE_DOCKER_HOST=$(yq '.docker.domain' "$CONFIG_FILE")
    # Check if yq succeeded or if registry.domain is empty
    if [ $? -ne 0 ] || [ -z "$REMOTE_DOCKER_HOST" ]; then
        echo "Error: Failed to read registry.domain from file with yq."
        exit 1
    fi
else
    echo "yq is not installed, using default value for docker host."
    REMOTE_DOCKER_HOST=$DEFAULT_DOCKER_HOST
fi

# You MUST use the domain defined in the configuration file: docker.domain
# The certificates are generated for that specific domain
CONTEXT_NAME=correctomatic_$ENVIRONMENT
CERTIFICATES_DIR="${HOME}/.correctomatic/"$ENVIRONMENT"/certs"

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
