const valueReplacer = require('../openidl-tools/value-replacer')

let args = process.argv.slice(2)
let nodeType = args[0]
console.log('applying secrets for ' + nodeType)
const secrets = require('./' + nodeType + '-dev-config-secrets.json')

valueReplacer.replaceVariablesInFolder('./config/config-dev-' + nodeType, secrets)
valueReplacer.validateNoVariablesRemainInFolder('./config/config-dev-' + nodeType, secrets)
