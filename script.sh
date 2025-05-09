#!/bin/bash

# This script is used to build and push the backstage community plugin todo to quay.io
echo "Setting Yarn version. Should now show $YARN_VERSION..."
set yarn version $YARN_VERSION
echo "Yarn version: $(yarn --version)"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "janus-cli version: $(janus-cli --version)"
echo "backstage-cli version: $(backstage-cli --version)"

echo "Cloning the Git repository..."
git clone $GIT_REPO

cd $ROOT_FOLDER
START_LOC=$(pwd)
echo "Working from $START_LOC"

# Performing initial Yarn task
echo "Performing yarn install..."
yarn install

# Performing typescript checking task
echo "Performing typescript compiler check (tsc)..."
yarn tsc

# Export the backend plugin as a dynamic plugin.
cd $START_LOC/$BACKEND_FOLDER
echo "Backend directory: $(pwd)"
echo "Exporting backend plugin..."
janus-cli package export-dynamic-plugin

# Export the frontend plugin as a dynamic plugin.
cd $START_LOC/$FRONTEND_FOLDER
echo "Frontend directory: $(pwd)"
echo "Exporting frontend plugin..."
janus-cli package export-dynamic-plugin


# login to quay.io
echo "Getting ready to package and push the dynamic plugins to Quay.io"
echo "Logging into quay.io as $QUAY_USERNAME..."
podman login -u=$QUAY_USERNAME -p=$QUAY_PASSWORD quay.io

# Return to the workspace root folder
cd $START_LOC #we should be in workspaces/todo
echo "Exporting dynamic plugins from: $(pwd)" 

# Build the dynamic plugin OCI image locally with podman
echo "Building the image: $QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG"
janus-cli package package-dynamic-plugins --tag quay.io/$QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG

# Push the dynamic plugin OCI image to quay.io
echo "Pushing the image to Quay.io as: $QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG"
podman push quay.io/$QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG
echo "Your dynamic plugin image has now been uploaded to Quay.io."
echo "Exiting..."