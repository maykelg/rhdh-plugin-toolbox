# Use an Ubuntu base image
FROM ubuntu:22.04

# ENV Arguments expected:
ARG YARN_VERSION
ARG NODE_VERSION
ARG JANUS_CLI_VERSION
ARG BACKSTAGE_CLI_VERSION
RUN echo "YARN_VERSION is set to: ${YARN_VERSION}"
RUN echo "NODE_VERSION is set to: ${NODE_VERSION}"
RUN echo "JANUS_CLI_VERSION is set to: ${JANUS_CLI_VERSION}"
RUN echo "BACKSTAGE_CLI_VERSION is set to: ${BACKSTAGE_CLI_VERSION}"

# Set the working directory
WORKDIR /app

# Install necessary dependencies for building Node.js and other tools
RUN apt-get update && \
    apt-get install -y \
    curl \
    tar \
    gzip \
    xz-utils \
    git \
    build-essential \
    wget \
    libssl-dev \
    libreadline-dev \
    zlib1g-dev \
    libffi-dev \
    bash \
    podman \
    slirp4netns \ 
    fuse-overlayfs 

# Set the NVM directory and create it
ENV NVM_DIR=/root/.nvm
RUN mkdir -p ${NVM_DIR}

# Install Node.js using nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install ${NODE_VERSION} \
    && nvm use ${NODE_VERSION} \
    && nvm alias default ${NODE_VERSION}

# Make nvm available in subsequent shell sessions
ENV PATH="${NVM_DIR}/versions/node/v${NODE_VERSION}/bin:${PATH}"

# Installing and activating YARN using corepack
RUN echo "Enabling Corepack for Yarn version ${YARN_VERSION}..."
RUN corepack enable yarn

RUN echo "Preparing Corepack (activating) yarn version ${YARN_VERSION}..."
RUN corepack prepare yarn@${YARN_VERSION} --activate

RUN echo "Telling corepack to use yarn version ${YARN_VERSION}..."
RUN corepack use yarn@${YARN_VERSION}

# Install the Janus CLI locally
RUN npm install -g @janus-idp/cli@${JANUS_CLI_VERSION} --yes
RUN npm install -g @backstage/cli@${BACKSTAGE_CLI_VERSION} --yes

# Add the file script.sh to the image
ADD script.sh /app/script.sh
RUN chmod +x /app/script.sh

# Set the entrypoint to /bin/bash if you want to work interactively
ENTRYPOINT ["/app/script.sh"]

# Optionally, set the default command.
#CMD ["bash", "./app/script.sh"]
