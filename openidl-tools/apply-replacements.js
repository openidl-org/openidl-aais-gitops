const valueReplacer = require('./value-replacer')
const secrets = require('./config/config-secrets.json')

valueReplacer.replaceVariablesInFolder('./temp/config', secrets)
