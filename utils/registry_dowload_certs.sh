#! /usr/bin/env bash
REGISTRY_DOMAIN=registry.correctomatic.alvaromaceda.es

sudo mkdir -p /etc/docker/certs.d/$REGISTRY_DOMAIN

openssl s_client -showcerts -connect $REGISTRY_DOMAIN:443 </dev/null 2>/dev/null | openssl x509 -outform PEM > /tmp/$REGISTRY_DOMAIN.crt

sudo cp /tmp/$REGISTRY_DOMAIN.crt /etc/docker/certs.d/$REGISTRY_DOMAIN/
