# Open Source Routing Machine: The OpenStreetMap Data Routing Engine hosted on Azure

This code uses the docker image provided by [OSRM](https://github.com/project-osrm/osrm-backend/pkgs/container/osrm-backend)

The goal has been to provide the user with an option to set up the OSRM backend on Windows Azure.

### remarks

- Dockerfile uses the mapping data for Denmark only. You can easily change that by editing the instructions and locating the link to your prefered mapping file on https://download.geofabrik.de/

The repository is build around running the image on an instance of an Azure Container which hosts the docker image provided.

1. You can run the deploy/deploy.ps1 file locally. You need to change the Azure subscription key beforehand. You find your own key on the Subscriptions page on Azure.

2. You can run the code as an Azure DevOps Pipeline by utilizing the azure-pipelines.yaml file.

You need the following to use this code:

- An Azure account and access to provision and administer Azure resources

deploy.ps1 will setup the following for you:

- Resource group
- Container Registry
- Container 

deploy1.ps will finish, if successful, with outputting the DNS where you can find your container instance running.

When finished provisioning you can start your route API requests, e.g.

https://{YOUR-DNS-NAME}/route/v1/driving/55.495972,9.473052;55.728760,12.437280?steps=true

From the https://zerfro.com team.