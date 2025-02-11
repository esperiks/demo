# Info

Sjekk om API KEY fortsatt er gyldig. Om den ikke er det, lag ny APIKEY og legg denne inn i Key Vault. Sjekk hvilken rolle som må benyttes

```shell
az grafana api-key create --key <name of created api key> --name <name of grafana instance> --resource-group <name of rg> --role editor --time-to-live 1y --output json
```

## Storage account

Hent ut Storage Accounten sin access key og sett denne som envir. 

```
export ARM_ACCESS_KEY=$(az keyvault secret show --name <name> --vault-name <name> --query value -o tsv)
```

## Terraform

Kjøres med 

```
terraform init

terraform plan -out main.tfplan

terraform apply main.tfplan
```
