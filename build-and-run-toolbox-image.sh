#!/bin/sh

ENV_FILE="./.env"

# Source the environment variables from config.env
source $ENV_FILE

# Build the toolbox image using the Dockerfile from the current directory
echo "Building the toolbox image: $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG"
podman build --build-arg-file $ENV_FILE -t $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG .

# Run the toolbox image and remove it after exit
echo "Running toolbox image: $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG"
podman run -it --rm --env-file "$ENV_FILE" $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG
