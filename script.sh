#!/bin/bash

# This script is used to build and push the backstage community plugin todo to quay.io
echo "Yarn version: $(yarn --version)"
# echo "Backstage CLI version: $(backstage-cli --version)"
# echo "Janus CLI version: $(janus-cli --version)"
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

echo "Cloning the community plugins repository..."
git clone https://github.com/backstage/community-plugins

cd community-plugins/workspaces/todo
pwd

# Performing initial Yarn tasks
echo "Performing Yarn installation and the Typescript compiler check..."
yarn install
yarn tsc

# Export backend plugin.
cd plugins/todo-backend
pwd
echo "Exporting backend plugin..."
npx @janus-idp/cli@latest package export-dynamic-plugin

# Export frontend plugin.
cd ../todo
pwd
echo "Exporting frontend plugin..."
npx @janus-idp/cli@latest package export-dynamic-plugin

# login to quay.io
echo "Logging in to quay.io as $QUAY_USERNAME..."
podman login -u=$QUAY_USERNAME -p=$QUAY_PASSWORD quay.io

cd ../.. #we should be in workspaces/todo
pwd 

# build the image
echo "Building the image: $QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG"
npx @janus-idp/cli@latest package package-dynamic-plugins --tag quay.io/$QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG

# push the image to quay.io
echo "Pushing the image: $QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG"
podman push quay.io/$QUAY_USERNAME/$QUAY_IMAGE_NAME:$QUAY_IMAGE_TAG