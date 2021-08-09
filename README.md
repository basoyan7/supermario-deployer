# Supermario-Deployer
## Requirements
* terraform >= 0.15
* docker >=19.0

## How to deploy
### export AWS connection details
* `export TF_VARS_aws_access_key_id=<value>`
* `export TF_VARS_aws_secret_access_key=<value>`

### Init and Apply
* `terraform init`
* `terraform apply -auto-approve`