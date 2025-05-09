# RHDH Plugin Toolbox & Dynamic Plugin Builder

The **RHDH Plugin Toolbox** is a container based utility project intended to assist with building dynamic plugins for Red Hat Developer Hub (RHDH). This repository contains sample scripts and Dockerfiles that streamline the process of building and packaging dynamic plugins for use with RHDH. 

As it stands, by following the instructions below you can build a dynamic plugin in a few munites and with very few upfront requirements or pre-requisites. You don't even need to be all that familiar with NodeJS, or Yarn, or RHDH. If nothing else, you can browse through this repo to familiarise yourself with the tools and commands required to package regular Backstage plugins as dynamic plugins for use with RHDH.

## Features

- **No NodeJS or Yarn Required**: Contains everything required to build and package a dynamic plugin for RHDH.
- **Dynamic Plugin Conversion**: Converts and packages the community 'TODO' plugin as an RHDH dynamic plugin.
- **Automatic Plugin OCI Image Push**: Pushes the resulting dynamic TODO plugin to your Quay image registry.

## Prerequisites

- Podman installed on your system.
- A Quay.io Account (Free)

## Getting Started

1. Clone this repository:

    ```bash
    git clone https://github.com/benwilcock/rhdh-plugin-toolbox.git
    cd rhdh-plugin-toolbox # You'll work in this folder
    ```

2. Setup your preferred environment variables:

    ```bash
    cp sample.env .env
    nano .env # Set your preferred values using the text editor
    ```

2. Build the toolbox image and TODO plugin using the provided script:

    ```bash
    ./build-and-run-toolbox-image.sh # builds the toolbox image and uses it to create your plugin
    ```

3. (Optional) Configure & Test the TODO Plugin In [RHDH Local](https://github.com/redhat-developer/rhdh-local)

    Add the following to your `dynamic-plugins.override.yaml` file:

    ```yaml
    plugins:

      # Activate and configure the TODO Frontend Plugin
      - package: oci://quay.io/<your-quay-repo>/backstage-community-plugin-todo:latest!backstage-community-plugin-todo
        disabled: false
        pluginConfig:
          dynamicPlugins:
              frontend:
                backstage-community.plugin-todo:
                  mountPoints:
                  - mountPoint: entity.page.todo/cards
                      importName: EntityTodoContent
                  entityTabs:
                  - path: /todo
                      title: Todo
                      mountPoint: entity.page.todo
      # Activate and configure the TODO Backend Plugin
      - package: oci://quay.io/<your-quay-repo>/backstage-community-plugin-todo:latest!backstage-community-plugin-todo-backend
        disabled: false
    ```

    When you boot [RHDH Local](https://github.com/redhat-developer/rhdh-local) with this configuration in place (`podman compose up`), your dynamic plugin will be installed and you can then test that the [Todo plugin](https://github.com/backstage/community-plugins/tree/main/workspaces/todo/plugins/todo) is working correctly. The plugin works with catalog entities that have "// TODO:" lines in their code on GitHub. If the correct conditions are met, and the plugin is working, you should see a "Todo" TAB in catalog entities where the associated codebase contains the necessary todo line (try this [example](https://github.com/benwilcock/springboot-djl-demo/blob/main/catalog-info.yml)).

## How it works

1. The toolbox image is built using the `Dockerfile` which includes the `script.sh` file as the `ENTRYPOINT` of the image.

   This image includes all the tools required to convert and build dynamic-plugins from source code. You will will be prompted to take positive action during the process.

2. The toolbox image is run and the `script.sh` is executed - causing the todo plugin to be built and pushed to Quay ready for testing.

   The script clones the Backstage `community-plugins` repository, initialises it with `yarn` and uses the `janus-cli` to create dynamic plugins for the frontend and backend of the `todo` plugin in the [todo workspace](https://github.com/backstage/community-plugins/tree/main/workspaces/todo). The resulting OCI image containing the dynamic plugin is then built and pushed to your user account in Quay.

3. The plugins are enabled in the RHDH configuration and run at boot.

   Based on the configuration added in step 3 above, RHDH downloads the OCI image of the todo plugin from your Quay repository and integrated their features with Red Hat Developer Hub for the benefit of your users.