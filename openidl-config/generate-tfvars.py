# importing the module
import json
import os
from jinja2 import Environment, FileSystemLoader, PackageLoader, select_autoescape, Template

env = Environment(
    loader=FileSystemLoader('openidl-configurations/templates/'),
    autoescape=select_autoescape()
)

# setup paths

carrierPath = 'config/carrier'
terraformPath = 'config/terrafom/carrier'

if not os.path.exists(carrierPath):
    os.makedirs(carrierPath)

if not os.path.exists(terraformPath):
    os.makedirs(terraformPath)

# reading the data from the file
with open('openidl-configurations/config/carrier-config.json') as f:
    textData = f.read()

data = json.loads(textData)

templateFileNames = [
    'carrier/terraform'
]

for templateFileName in templateFileNames:
    template = env.get_template(templateFileName + '-tfvars.j2')

    rendered = template.render(data)

    with open('config/terraform/' + templateFileName + '.tfvars', 'w') as f:
        f.write(rendered)
