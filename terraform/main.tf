# Create teams and add external groups
resource "grafana_team" "DFT" {
    name = "DFT"
    preferences {
        home_dashboard_uid = grafana_dashboard.home.uid
    }
}

# Create data sources for Github
# Secret values are stored in Azure Key Vault
data "azurerm_key_vault" "key" {
  name                = "dft-grafana-stg-kv"
  resource_group_name = "dft-grafana-stg-rg"
}

data "azurerm_key_vault_secret" "githubpat" {
  name         = "dft-grafana"
  key_vault_id = data.azurerm_key_vault.key.id
}

data "azurerm_key_vault_secret" "grafana_reader" {
  name         = "grafana-reader"
  key_vault_id = data.azurerm_key_vault.key.id
}

resource "grafana_data_source" "github" {
    type = "grafana-github-datasource"
    name = "GitHub"
    access_mode = "proxy"
    json_data_encoded = jsonencode({
        selectedAuthType = "personal-access-token"
    })
    secure_json_data_encoded = jsonencode({
        accessToken = data.azurerm_key_vault_secret.githubpat.value
    })
}

#################
# Create Folders and Dashboards

# Folder for Github dashboards
resource "grafana_folder" "github" {
    title = "Github"
}

resource "grafana_dashboard" "github" {
    config_json = templatefile("${path.module}/dashboards/github/github_default.tpl", { github_uid = grafana_data_source.github.uid })
    folder = grafana_folder.github.id
}


