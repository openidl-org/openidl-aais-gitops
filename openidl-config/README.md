This folder holds the configuration information for the application.
The config folder, specifically holds the templates for all the config files.

# getting started

1. make sure you have the jinja2 plugin in visual studio code (if you do, the .j2 files will have the jinja icon)
1. initialize python to the latest version - should have python3
1. install jinja `pip install jinja2`
1. set up the configuration file in the config directory based on the templates provided
1. run the make to generate the config files `make generate_config_files`
1. run the make to generate the tfvars file for terraform `make generate_tfvars_file`

# accessing the secrets from the command line

1. start up the port-forward to vault
    - connect kubectl to the blk cluster
      `aws --profile uat-role eks update-kubeconfig --region us-east-1 --name caru-dev-blk-cluster`
    - start the port forward
      `kubectl -n vault port-forward svc/vault 8200:8200`
1. install vault if not already installed
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/vault
    ```
1. setup the vault
    - export the url and unseal key
    ```
    export VAULT_ADDR=http://localhost:8200
    export VAULT_TOKEN=s.4a6Fo3fIZBurajVZyMcvTZgd
    ```
1. retrieve the keys
   `vault kv get -format=json config/config-caru/channel-config`
    - do this for each of the keys you want
