# RHDH Plugin Toolbox & Dynamic Plugin Builder

The **RHDH Plugin Toolbox** is a utility project designed to assist with building and testing plugins for Red Hat Developer Hub (RHDH). This repository contains scripts and Dockerfiles to streamline the development and packaging of dynamic plugins intended for use with RHDH. 


As it stands, by following the instructions below you can build a dynamic plugin in a few munites with very few upfront requirements or pre-requisites. You don't even need to be all that familiar with NodeJS, or Yarn, or RHDH. If nothing else, you can browse through this repo to familiarise yourself with the tools and commands required to package regular Backstage plugins as dynamic plugins for use with RHDH

## Features

- **No NodeJS or Yarn Required**: Contains everything required to build and package a dynamic plugin for RHDH.
- **Dynamic Plugin Concersion**: Converts and packages the community 'TODO' plugin as an RHDH dynamic plugin.
- **Automatic OCI Image Registration**: Pushes the resulting dynamic TODO plugin to the Quay image registry.

## Prerequisites

- Podman installed on your system.
- A Quay.io Account (Free)

## Getting Started

1. Clone the repository:

    ```bash
    git clone https://github.com/benwilcock/rhdh-plugin-toolbox.git
    cd rhdh-plugin-toolbox # work in this folder
    ```

2. Setup your environment variables:

   ```bash
   cp sample.env .env
   nano .env # Set your preferred values using the text editor
   ```

2. Build the TODO plugin using the provided scripts:

    ```bash
    ./build-and-run-toolbox-image.sh # builds the image and runs it in podman
    ```

3. (Optional) Configure & Run the TODO Plugin In [RHDH Local](https://github.com/redhat-developer/rhdh-local)

    Add the following to your `dynamic-plugins.override.yaml` file:

    ```yaml
    plugins:

    # TODO Plugin
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
    - package: oci://quay.io/<your-quay-repo>/backstage-community-plugin-todo:latest!backstage-community-plugin-todo-backend
        disabled: false
    ```

    Test that the plugin is working correctly (requires catalog entities that have "// TODO:" entries in the code on GitHub). If the correct conditions are met and the plugin is working, you should see a "Todo" TAB in catalog entities where the associated codebase [example](https://github.com/benwilcock/springboot-djl-demo/blob/main/catalog-info.yml) has "TODO:" entries in its code.

## How it works

1. The toolbox image is built using the `Dockerfile` which includes the `script.sh` file as the `ENTRYPOINT` of the image.

   This image includes all the tools required to convert and build dynamic-plugins from source code.

2. The toolbox image is run and the `script.sh` is executed - causing the todo plugin to be built and pushed to Quay ready for testing.

   The script clones the Backstage `community-plugins` repository, initialises it with `yarn` and used the `janus-cli` to create dynamic plugins for the frontend and backend of the `todo` plugins in the `todo` workspace. The resulting OCI image is then built and pushed to your user account in Quay.

3. The plugins are enabled in the RHDH configuration and run at boot.

   Based on the configuration added in step 3 above, RHDH downloads the OCI image of the todo plugin from your Quay repository and integrated their features with Red Hat Developer Hub fr the benefit of it's users.