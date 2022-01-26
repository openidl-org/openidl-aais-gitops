# importing the module
import json
import os
from jinja2 import Environment, FileSystemLoader, PackageLoader, select_autoescape, Template

env = Environment(
    # loader=PackageLoader("./openidl-configurations"),
    loader=FileSystemLoader('openidl-configurations/templates/'),
    autoescape=select_autoescape()
)

# setup paths

carrierPath = 'config/carrier'
k8sPath = 'config/k8s/carrier'

if not os.path.exists(carrierPath):
    os.makedirs(carrierPath)

if not os.path.exists(k8sPath):
    os.makedirs(k8sPath)

# reading the data from the file
with open('openidl-configurations/config/carrier-config.json') as f:
    textData = f.read()

data = json.loads(textData)

templateFileNames = [
    'carrier/channel-config',
    'carrier/connection-profile',
    'carrier/data-call-app-default-config',
    'carrier/data-call-app-mappings-config',
    'carrier/data-call-processor-default-config',
    'carrier/data-call-processor-mappings-config',
    'carrier/data-call-processor-metadata-config',
    'carrier/default-config',
    'carrier/email-config',
    'carrier/insurance-data-manager-channel-config',
    'carrier/insurance-data-manager-default-config',
    'carrier/insurance-data-manager-mappings-config',
    'carrier/insurance-data-manager-metadata-config',
    'carrier/listener-channel-config',
    'carrier/local-cognito-admin-config',
    'carrier/local-cognito-config',
    'carrier/local-db-config',
    'carrier/local-kvs-config',
    'carrier/local-vault-config',
    'carrier/s3-bucket-config',
    'carrier/target-channel-config',
    'carrier/ui-mappings-config',
    'carrier/unique-identifiers-config',
    'carrier/utilities-fabric-config',
    'carrier/utilities-mappings-config',
    'carrier/utilties-admin-config'
]

for templateFileName in templateFileNames:
    template = env.get_template(templateFileName + '-json.j2')

    rendered = template.render(data)

    with open('config/' + templateFileName + '.json', 'w') as f:
        f.write(rendered)

template = env.get_template('carrier/global-values-carrier-yaml.j2')

rendered = template.render(data)

with open('config/k8s/carrier/global-values-dev-carrier.yaml', 'w') as f:
    f.write(rendered)
