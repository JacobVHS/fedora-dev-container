#!/bin/bash

# Variables
REGISTRY='a1containers.azurecr.io'
IMAGE_NAME='jacob-dev-ee'
VERSION='1.0.4'

# echo 'Loggin into container registry!'
# podman login $REGISTRY

echo 'Building container image!'
podman build . -t $REGISTRY/$IMAGE_NAME:latest
podman tag $REGISTRY/$IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:$VERSION

echo 'Pushing container image to registry $REGISTRY as $REGISTRY/$IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:$VERSION'
podman push $REGISTRY/$IMAGE_NAME:latest $REGISTRY/$IMAGE_NAME:$VERSION

