#! /usr/bin/env bash
set -e

VPS_USER="${1:-ansible}"
VPS_HOST="${2:-correctomatic_vps}"
CERTIFICATES_DIR="${3:-${HOME}/.config/correctomatic/certs}"

echo "Downloading certificates from $VPS_USER@$VPS_HOST to $CERTIFICATES_DIR"

# TO-DO: garbage at the start of the file

mkdir -p "$CERTIFICATES_DIR"
echo -n "Password for $VPS_USER:" && read -s VPS_PASSWORD

# Server Certificate authority
sshpass -p "$VPS_PASSWORD" ssh -tt $VPS_USER@$VPS_HOST "echo $VPS_PASSWORD | sudo -S cat /etc/docker/ca/ca-certificate.pem" > "$CERTIFICATES_DIR/ca-certificate.pem"

# Client keys
sshpass -p "$VPS_PASSWORD" ssh -tt $VPS_USER@$VPS_HOST "echo $VPS_PASSWORD | sudo -S cat /etc/docker/certs/correctomatic-client-certificate.pem" > "$CERTIFICATES_DIR/correctomatic-client-certificate.pem"
sshpass -p "$VPS_PASSWORD" ssh -tt $VPS_USER@$VPS_HOST "echo $VPS_PASSWORD | sudo -S cat /etc/docker/certs/correctomatic-private-key.pem" > "$CERTIFICATES_DIR/correctomatic-private-key.pem"

# TO-DO: change permissions to private key

echo "Certificates downloaded to $CERTIFICATES_DIR"
echo "CHECK THE CERTIFICATES: if you had an error typing the password, the files will have error messages"
