This folder holds the configuration information for the application.
The config folder, specifically holds the templates for all the config files.

# getting started

make sure you have the jinja2 plugin in visual studio code (if you do, the .j2 files will have the jinja icon)

initialize python to the latest version - should have python3

install jinja

`pip install jinja2`

set up the configuration file in the config directory based on the templates provided

run the make

`make generate_config_files`

# accessing the secrets from the command line

start up the port-forward to vault

-   connect kubectl to the blk cluster

`aws --profile uat-role eks update-kubeconfig --region us-east-1 --name caru-dev-blk-cluster`

-   start the port forward

`kubectl -n vault port-forward svc/vault 8200:8200`

install vault if not already installed

```
brew tap hashicorp/tap
brew install hashicorp/tap/vault
```

setup the vault

-   export the url and unseal key

`export VAULT_ADDR=http://localhost:8200`
`export VAULT_TOKEN=s.4a6Fo3fIZBurajVZyMcvTZgd`

retrieve the keys

`vault kv get -format=json config/config-caru/channel-config`

-   do this for each of the keys you want
