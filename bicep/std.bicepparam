using 'main.bicep'

// Generic parameters
param env = 'stg'
param location = 'westeurope'

// Resource group parameters
param rgName = 'grafana-${env}-rg'
param tagsRG = {
  Owner: '*'
  ManagedBy: 'dft'
  Description: 'Azure Managed Grafana. Includes Azure Managd Grafana, Key Vault and Storage Account for Terraform state file.'
  Environment: env
}

// Storage account parameters
param storageAccountName = 'grafanastate'

param tagsStorageAccount = {
  Environment: env
  Description: 'Storage account for storing Terraform state files'
}

param ipRules = [
  {
    value: '8.8.8.8'
    action: 'Allow'
  }
]

// Key vault parameters
param keyvaultName = 'grafana-${env}-kv'
