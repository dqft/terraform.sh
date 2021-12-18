# terraform.sh
A shell script to help handling various Terraform projects settings and CLI versions, allowing deduplicated environment variables according to a hierarchy per folder.

## Install
```bash
sudo curl -L --fail https://raw.githubusercontent.com/dqft/terraform.sh/main/terraform.sh -o /usr/local/bin/terraform
sudo chmod +x /usr/local/bin/terraform
```

## Description
The script first loads your HOME .env file, then it recursively searches for .env files from the root folder `/` until the current folder, looking only into folders that are part of the current path.
Hierarchy is established in a way that a variable in the current folder's .env file overrides the same variable in a parent folder.

```zsh
~/src
❯ cat .env
# Use a specific Terraform version globally
TERRAFORM_VERSION=0.13.5
TF_VAR_hello=world

~/src
❯ cat ~/src/work/.env
# Work scoped environment variables
DOCKER_REGISTRY_USER=...
DOCKER_REGISTRY_PASS=...

~/src
❯ cat ~/src/personal/move-to-latest-terraform/.env
# Use latest pulled Terraform image for this project
TERRAFORM_VERSION=latest
```