# Private registry

The VPS has a private Docker registry running. This registry is used to store Docker images that are used by the Correctomatic. The registry is secured with a self-signed certificate and basic authentication.

This document explains how to work with the registry.

## Prepare your local machine to work with the registry

Docker needs to trust the self-signed certificate used by the virtual machine. You won't need this in production because you will have a real certificate. **YOU MUST DO THIS EACH TIME THE CERTIFICATES ARE REGENERATED**

There is a script that does this for you: `utils/registry_download_certs.sh`.

## Push images to the registry

You need to follow these steps to push an image to the VPS:

1) Connect to your **local** Docker daemon
2) Tag the image
3) Push the image to the VPS

Example:
```sh
DOCKER_REGISTRY=<registry>
IMAGE=<image>:<tag>

docker image tag $IMAGE $DOCKER_REGISTRY/$IMAGE
docker image push $DOCKER_REGISTRY/$IMAGE
```


TO-DO: check this frontend
https://github.com/Joxit/docker-registry-ui


## Pull images in the VPS

To be able to use the images in the VPS, you need to pull them from the registry. You can use the following commands:

```sh
docker pull registry.correctomatic.alvaromaceda.es/<image>:<tag>
```

## Registry frontend

The easiest way to interact with the registry is using a frontend. You can use the docker-compose.yml files in the `utils/registry_frontend` directory to run a frontend in the VPS.

## List images in the registry

```sh
DOCKER_REGISTRY=<registry>
REGISTRY_USER=<registry_user>
REGISTRY_PASS=<password>

curl -k -u "$REGISTRY_USER:$REGISTRY_PASS" -X GET https://$DOCKER_REGISTRY/v2/_catalog
```

## Remove images from the registry

Removing images from the registry is not as straightforward as removing them from the local machine. You need to use the registry API to delete them. See the document `utils/delete_image_from_registry.md` for more information.
