#!/bin/sh

ENV_FILE="./.env"

# Source the environment variables from config.env
source $ENV_FILE

# Build the toolbox image using the Dockerfile from the current directory
# Ask the user if they want to turn off the image cache
read -p "Have you changed the version numbers of any of the tools listed in the .env file? (y/n): " NO_CACHE

if [ "$NO_CACHE" = "y" ]; then
    echo "Building the toolbox image with image cache OFF: $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG"
    podman build --no-cache --build-arg-file $ENV_FILE -t $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG .
else
    echo "Building the toolbox image with image cache ON: $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG"
    podman build --build-arg-file $ENV_FILE -t $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG .
fi
# You can use --no-cache if you want to ensure a fresh build every time

# Run the toolbox image and remove it after exit
echo "Running the script contained in the toolbox image: $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG"
podman run -it --rm --env-file "$ENV_FILE" $TOOLBOX_IMAGE_NAME:$TOOLBOX_IMAGE_TAG
