targetScope = 'subscription'

// shared
@description('Required. The location of the resources')
@allowed(
  [
    'westeurope'
  ]
)
param location string

@description('Required. Sets the environment')
@allowed(
  [
    'dev'
    'stg'
    'prod'
  ]
)
param env string


// resource group
@description('Required. Name of the resource group to deploy the resources to.')
param rgName string

@description('Required. The tags of the resource group')
param tagsRG object

// Define the role definitions
var Grafana_admin_Role_Definition = '22926164-76b3-42b3-bc55-97df8dab3e41'
var Grafana_viewer_Role_Definition = '60921a7e-fef1-4a43-9b16-a26c52ad4769'

// Define the role assignments
var Grafana_admin_prod = '*'
var Grafana_OEF_dashboard_reader_prod = '*'
var Grafana_read_prod = '*'

// Create the resource group
module rg 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: '${deployment().name}-rg'
  params: {
    name: rgName
    tags: tagsRG
    roleAssignments: [
      {
        principalId: Grafana_admin_prod
        roleDefinitionIdOrName: Grafana_admin_Role_Definition
      }
      {
        principalId: Grafana_OEF_dashboard_reader_prod
        roleDefinitionIdOrName: Grafana_viewer_Role_Definition
      }
      {
        principalId: Grafana_read_prod
        roleDefinitionIdOrName: Grafana_viewer_Role_Definition
      }
    ]
  }
}

module grafana '.bicep/grafana.bicep' = {
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
  name: 'azure_managed_grafana'
  params: {
    location: location
    env: env
  }
}

// Storage account for storing Terraform state files
@description('Required. The name of the storage account')
@maxLength(24)
param storageAccountName string

@description('Optional. The tags for the storage account. Default is {}')
param tagsStorageAccount object = {}

@description('Optional. The IP rules for the storage account. Default is []')
param ipRules array = []

module storageAccount 'br/public:avm/res/storage/storage-account:0.14.3' = {
  scope: resourceGroup(rgName)
  name: '${deployment().name}-sa'
  dependsOn: [
    rg
  ]
  params: {
    name: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    tags: tagsStorageAccount
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: ipRules
    }
    blobServices: {
      name: 'tfstate'
      containers: [
        {
          name: 'tfstate'
          publicAccess: 'None'
        }
      ]
    }
  }
}

// Key Vault for storing secrets
@description('Required. The name of the key vault')
param keyvaultName string

module keyVault 'br/public:avm/res/key-vault/vault:0.10.2' = {
  scope: resourceGroup(rgName)
  dependsOn: [
    rg
  ]
  name: '${deployment().name}-kv'
  params: {
    name: keyvaultName
    location: location
    sku: 'standard'
    enableSoftDelete: true
    softDeleteRetentionInDays: 30
  }
}
