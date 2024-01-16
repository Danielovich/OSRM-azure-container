param(
  [Parameter(Mandatory=$false)]
  [string]
  $dockerFilePath = ".\Dockerfile"
)

$location = "westeurope"
$dockerImageTag = "v1"

$dockerImage = "routing-image-zerfro"
$containerDNSName = "routing-zerfro"
$containerName = "routing-zerfro-container"
$containerRegistryName = "containerregistryzerfro"
$resourceGroup = "routing-zerfro"

##################################################
# Subscription
##################################################
$command = az account set `
  --subscription "9a29bc1a-8cc5-4b2f-9d44-54c7a7b54f87"

##################################################
# No reason to continue if this should fail
##################################################
Write-Host "-Building docker image $($dockerImage + ":" + $dockerImageTag)" -ForegroundColor DarkYellow

docker build -t ($dockerImage + ":" + $dockerImageTag) -f $dockerFilePath .

##################################################
# Resource group
##################################################
Write-Host "-Creating resource group" -ForegroundColor DarkYellow
$command = az group create `
  --name $resourceGroup `
  --location $location

##################################################
# Azure Container Registry
##################################################
Write-Host "-Create Azure Container Registry" -ForegroundColor DarkYellow
$command = az acr create `
  --name $containerRegistryName `
  --resource-group $resourceGroup `
  --location $location `
  --sku Basic `
  --admin-enabled true

Write-Host "-Login to Azure Container Registry" -ForegroundColor DarkYellow
az acr login --name $containerRegistryName

$acrLoginServer = az acr show `
  --name $containerRegistryName `
  --query loginServer `
  --output tsv

##################################################
# Tag and Push docker image to Azure Container Registry
##################################################

# Tag the image for ACR
docker tag ($dockerImage + ":" + $dockerImageTag) $acrLoginServer/$($dockerImage + ":" + $dockerImageTag)

# Push the image to ACR
docker push $acrLoginServer/$($dockerImage + ":" + $dockerImageTag)

##################################################
# Azure Container 
##################################################

Write-Host "-Getting credentials from Azure Container Registry" -ForegroundColor DarkYellow
$acrCredentialsJson = az acr credential show `
 --name $containerRegistryName
$acrCredentials = $acrCredentialsJson | ConvertFrom-Json
$username = $acrCredentials.username
$password = $acrCredentials.passwords[0].value


Write-Host "-Create Azure Container" -ForegroundColor DarkYellow
$command = az container create `
    --name $containerName `
    --resource-group $resourceGroup `
    --image "$acrLoginServer/$($dockerImage + ":" + $dockerImageTag)" `
    --dns-name-label $containerDNSName `
    --ports 5000 `
    --registry-login-server $acrLoginServer `
    --registry-username $username `
    --registry-password $password


Write-Host "-Looking up DNS for deployed container" -ForegroundColor DarkYellow
$containerFQDN = az container show `
  --name $containerName `
  --resource-group $resourceGroup `
  --query ipAddress.fqdn `
  --output tsv

Write-Host "$acrLoginServer/$($dockerImage + ":" + $dockerImageTag) deployed to DNS : $containerFQDN"
