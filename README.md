---
title: "Docker Deployment | OpenMetadata Container Setup"
source: "https://docs.open-metadata.org/v1.12.x/deployment/docker"
author:
  - "[[OpenMetadata Documentation]]"
published:
created: 2026-02-25
description: "Deploy the platform using Docker containers to simplify setup, scaling, and local testing without needing external dependencies."
tags:
  - "clippings"
---

# OpenMetadata Docker Deployment Guide

## Docker Deployment

This guide will help you set up the OpenMetadata Application using Docker Deployment. Before starting with the deployment make sure you follow all the below Prerequisites.

## Docker Deployment Architecture

![Docker Deployment Architecture](https://mintcdn.com/openmetadata/BD_VpubLZxqEpcO8/public/images/deployment/docker/om_docker_architecture.png?w=280&fit=max&auto=format&n=BD_VpubLZxqEpcO8&q=85&s=c14c4ec931947c9b235d2cd0aa124266)

Docker Deployment Architecture

## Prerequisites

For Production Deployment using Docker, we recommend bringing your own Databases and ElasticSearch Engine and not rely on quickstart packages.

### Configure External Orchestrator Service (Ingestion Service)

OpenMetadata requires connectors to be scheduled to periodically fetch the metadata, or you can use the OpenMetadata APIs to push the metadata as well
1. OpenMetadata Ingestion Framework is flexible to run on any orchestrator. However, we built an ability to deploy and manage connectors as pipelines from the UI. This requires the Airflow container we ship.
2. If your team prefers to run on any other orchestrator such as prefect, dagster or even GitHub workflows. Please refer to our recent webinar on [How Ingestion Framework works](https://www.youtube.com/watch?v=i7DhG_gZMmE&list=PLa1l-WDhLreslIS_96s_DT_KdcDyU_Itv&index=10)

### Docker (version 20.10.0 or higher)

[Docker](https://docs.docker.com/get-started/overview/) is an open-source platform for developing, shipping, and running applications. It enables you to separate your applications from your infrastructure, so you can deliver software quickly using OS-level virtualization. It helps deliver software in packages called Containers.To check what version of Docker you have, please use the following command.If you need to install Docker, please visit [Get Docker](https://docs.docker.com/get-docker/).

### Docker Compose (version v2.2.3 or greater)

The Docker compose package enables you to define and run multi-container Docker applications. The compose command integrates compose functions into the Docker platform, making them available from the Docker command-line interface ( CLI). The Python packages you will install in the procedure below use compose to deploy OpenMetadata.
- **MacOS X**: Docker on MacOS X ships with compose already available in the Docker CLI.
- **Linux**: To install compose on Linux systems, please visit the Docker CLI command documentation and follow the instructions.
To verify that the docker compose command is installed and accessible on your system, run the following command.Upon running this command you should see output similar to the following.

#### Install Docker Compose Version 2 on Linux

Follow the instructions [here](https://docs.docker.com/compose/cli-command/#install-on-linux) to install docker compose version 2
1. Run the following command to download the current stable release of Docker Compose This command installs Compose V2 for the active user under $HOME directory. To install Docker Compose for all users on your system, replace ` ~/.docker/cli-plugins` with `/usr/local/lib/docker/cli-plugins`.
2. Apply executable permissions to the binary
3. Test your installation
Create a new directory for OpenMetadata and navigate into that directory.

### 2\. Download Docker Compose Files from GitHub Releases

Download the Docker Compose files from the [Latest GitHub Releases](https://github.com/open-metadata/OpenMetadata/releases/latest).The Docker compose file name will be `docker-compose-openmetadata.yml`.This docker compose file contains only the docker compose services for OpenMetadata Server. Bring up the dependencies as mentioned in the [prerequisites](https://docs.open-metadata.org/v1.12.x/deployment/#configure-openmetadata-to-use-external-database-and-search-engine) section.You can also run the below command to fetch the docker compose file directly from the terminal - In the previous [step](https://docs.open-metadata.org/v1.12.x/deployment/#2.-download-docker-compose-files-from-github-releases), we download the `docker-compose` file.Identify and update the environment variables in the file to prepare openmetadata configurations.For MySQL Configurations, update the below environment variables - For ElasticSearch Configurations, update the below environment variables - For OpenSearch Configurations, update the below environment variables -

If you want to separate indexes for production and non-production environments, you can set the `clusterAlias` in the configuration file.

For Ingestion Configurations, update the below environment variables -

When setting up environment file if your custom password includes any special characters then make sure to follow the steps [here](https://github.com/open-metadata/OpenMetadata/issues/12110#issuecomment-1611341650).

### 4\. Start the Docker Compose Services

Run the below command to deploy the OpenMetadata - You can validate that all containers are up by running with command `docker ps`.In a few seconds, you should be able to access the OpenMetadata UI at [http://localhost:8585](http://localhost:8585/)

## Port Mapping / Port Forwarding

We are shipping the OpenMetadata server and UI at container port and host port `8585`. You can change the host port number according to your requirement. As an example, You could update the ports to serve OpenMetadata Server and UI at port `80` To achieve this -
- You just have to update the ports mapping of the openmetadata-server in the `docker-compose.yml` file under `openmetadata-server` docker service section.
- Once the port is updated if there are any containers running remove them first using `docker compose down` command and then recreate the containers once again by below command
You may put one or more OpenMetadata instances behind a load balancer for reverse proxying. To do this you will need to add one or more entries to the configuration file for your reverse proxy.

### Nginx

To use OpenMetadata behind Nginx reverse proxy, add an entry resembling the following the http context of your Nginx configuration file for each OpenMetadata instance.If you are running OpenMetadata in AWS, it is recommended to use [Amazon RDS](https://docs.aws.amazon.com/rds/index.html) and [Amazon OpenSearch Service](https://docs.aws.amazon.com/opensearch-service/?id=docs_gateway).We support
- Amazon RDS (MySQL) engine version 8 or higher
- Amazon OpenSearch (ElasticSearch) engine version up to 8.11.4 or Amazon OpenSearch engine version up to 2.19
- Amazon RDS (PostgreSQL) engine version 12 or higher
Note:- When using AWS Services the SearchType Configuration for elastic search should be `opensearch`, for both cases ElasticSearch and OpenSearch, as you can see in the ElasticSearch configuration example.For Production Systems, we recommend Amazon RDS to be in Multiple Availability Zones. For Amazon OpenSearch (or ElasticSearch) Service, we recommend Multiple Availability Zones with minimum 3 Master Nodes.Once you have the RDS and OpenSearch Services Setup, you can update the environment variables below for OpenMetadata Docker Compose backed systems to connect with Database and ElasticSearch.Replace the environment variables values with the RDS and OpenSearch Service ones and then provide this environment variable file as part of docker compose command.

## Advanced

There are many scenarios where you would want to provide additional files to the OpenMetadata Server and serve while running the application. In such scenarios, it is recommended to provision docker volumes for OpenMetadata Application.

If you are not familiar with Docker Volumes with Docker Compose Services, Please refer to [official documentation](https://docs.docker.com/storage/volumes/#use-a-volume-with-docker-compose) for more information.

For example, we would like to provide custom JWT Configuration Keys to be served to OpenMetadata Application. This requires the OpenMetadata Containers to have docker volumes sharing the private and public keys. Let’s assume you have the keys available in `jwtkeys` directory in the same directory where your `docker-compose` file is available in the host machine.In scenarios where you need to provide a custom `openmetadata.yaml` configuration file to the OpenMetadata application, you can do so by mounting the file as a volume in the Docker container. This is especially useful for configurations that cannot be controlled through environment variables.We add the volumes section to mount the keys or `openmetadata.yaml` onto the docker containers create with docker compose as follows - The above example uses [bind mounts](https://docs.docker.com/storage/bind-mounts/#use-a-bind-mount-with-compose) to share files and directories between host machine and openmetadata container.Next, in your environment file, update the jwt configurations to use the right path from inside the container.Ensure that the default environment variables are set appropriately to complement the settings in your `openmetadata.yaml`.Once the changes are updated, if there are any containers running remove them first using `docker compose down` command and then recreate the containers once again by below command

## Troubleshooting

### Java Memory Heap Issue

If your openmetadata Docker Compose logs speaks about the below issue - This is due to the default JVM Heap Space configuration (1 GiB) being not enough for your workloads. In order to resolve this issue, head over to your custom openmetadata environment variable file and append the below environment variable The flag `Xmx` specifies the maximum memory allocation pool for a Java virtual machine (JVM), while `Xms` specifies the initial memory allocation pool.Restart the OpenMetadata Docker Compose Application using `docker compose --env-file <my-env-file> -f docker-compose.yml up --detach` which will recreate the containers with new environment variable values you have provided.If you are facing the below issue with PostgreSQL as Database Backend for OpenMetadata Application,It seems the Database User does not have sufficient privileges. In order to resolve the above issue, grant usage permissions to the PSQL User.

In the above command, replace `<openmetadata_psql_user>` with the sql user used by OpenMetadata Application to connect to PostgreSQL Database.

In the above command, replace `<openmetadata_psql_user>` with the sql user used by OpenMetadata Application to connect to PostgreSQL Database.

## Security

Please follow our [Enable Security Guide](https://docs.open-metadata.org/v1.12.x/deployment/docker/security) to configure security for your OpenMetadata installation.
1. Refer the [How-to Guides](https://docs.open-metadata.org/v1.12.x/how-to-guides) for an overview of all the features in OpenMetadata.
2. Visit the [Connectors](https://docs.open-metadata.org/v1.12.x/connectors) documentation to see what services you can integrate with OpenMetadata.
3. Visit the [API](https://docs.open-metadata.org/api-reference) documentation and explore the rich set of OpenMetadata APIs.[Configuring OpenMetadata to Run Under a Subpath](https://docs.open-metadata.org/v1.12.x/deployment/bare-metal/subpath)

[

Previous

](https://docs.open-metadata.org/v1.12.x/deployment/bare-metal/subpath)[

Enable Security (Docker) | OpenMetadata Docker Security

Next

](https://docs.open-metadata.org/v1.12.x/deployment/docker/security)



## Running OpenMetadata with MySQL and ElasticSearch using Docker Compose

```shell
docker compose --env-file env-mysql -f docker-compose-openmetadata-mysql.yml up -d
```


and when finished, here is how to stop the containers:

```shell   
docker compose --env-file env-mysql -f docker-compose-openmetadata-mysql.yml down
```


## Installation using Postgres instead of MySQL (NOT WORKING YET)

https://docs.open-metadata.org/v1.12.x/deployment/bare-metal#postgres-version-12-0-or-higher