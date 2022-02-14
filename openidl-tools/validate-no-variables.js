const valueReplacer = require('./value-replacer')
const secrets = require('./config/config-secrets.json')

valueReplacer.validateNoVariablesRemainInFolder('./test', secrets)
