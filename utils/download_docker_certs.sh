#! /usr/bin/env bash
set -e

VPS_USER="${1:-ansible}"
VPS_HOST="${2:-correctomatic_vps}"
CERTIFICATES_DIR="${3:-${HOME}/.correctomatic/certs}"

echo "Downloading certificates from $VPS_USER@$VPS_HOST to $CERTIFICATES_DIR"

mkdir -p "$CERTIFICATES_DIR"
echo -n "Password for $VPS_USER:" && read -s VPS_PASSWORD

# The certificates are not accessible to the user in the remote server
# This script creates a protected directory and copies the certificates to it
SCRIPT=$(cat <<EOF
# Creates protected directory
DOWNLOAD_DIR=/tmp/certificates_download

rm -Rf \$DOWNLOAD_DIR
mkdir \$DOWNLOAD_DIR
chmod 700 \$DOWNLOAD_DIR

# Copies neccecary files to the protected directory
CERTS_DIR=/etc/docker
echo $VPS_PASSWORD | sudo -S cp \$CERTS_DIR/ca/ca-certificate.pem \$DOWNLOAD_DIR/ca.pem
echo $VPS_PASSWORD | sudo -S cp \$CERTS_DIR/certs/correctomatic-client-certificate.pem \$DOWNLOAD_DIR/cert.pem
echo $VPS_PASSWORD | sudo -S cp \$CERTS_DIR/certs/correctomatic-private-key.pem \$DOWNLOAD_DIR/key.pem
echo $VPS_PASSWORD | sudo -S chown $VPS_USER \$DOWNLOAD_DIR/*
EOF
)
sshpass -p "$VPS_PASSWORD" ssh $VPS_USER@$VPS_HOST 'bash -s' <<< "$SCRIPT"

# Donwload the files to the local machine
sshpass -p "$VPS_PASSWORD" scp -r $VPS_USER@$VPS_HOST:/tmp/certificates_download/* $CERTIFICATES_DIR

echo "Certificates downloaded to $CERTIFICATES_DIR"
