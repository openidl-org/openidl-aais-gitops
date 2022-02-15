// this routine must be passed a json object containing the values to be replaced.
// the format of the file is:
/*
[
    {
        "name": "<value>"
    }    
]
*/

const fs = require('fs');
const path = require('path')

function replaceVariablesInFolder(folder, replacements) {
    // console.log('processing folder: ' + folder)
    // console.log(' replacing: ', JSON.stringify(replacements))
    fs.readdirSync(folder).forEach(file => {
        let absolute = path.join(folder, file)
        if (fs.statSync(absolute).isDirectory()) {
            return replaceVariablesInFolder(absolute, replacements)
        } else {
            return replaceVariablesInFile(absolute, replacements)
        }
    })

}

function replaceVariablesInFile(file, replacements) {
    // console.log(' processing file: ' + file)
    let result = fs.readFileSync(file, 'utf8')
    for (replacement of replacements) {
        let replacementString = '${' + replacement.name + '}'
        // console.log('  replacing: ' + replacement.name + ' with ' + replacement.value)
        do {
            let replacingString = replacement.value
            if (replacement.handleEndOfLine) {
                // console.log('   handling end of line')
                replacingString = replacingString.replace(/\n/g, '\\n')
            }
            result = result.replace(replacementString, replacingString);
        } while (result.indexOf(replacementString) > -1)
    }

    fs.writeFileSync(file, result, 'utf8');
}

function validateNoVariablesRemainInFolder(folder, replacements) {
    // console.log('validating folder: ' + folder)
    // console.log(' validating: ', JSON.stringify(replacements))
    fs.readdirSync(folder).forEach(file => {
        let absolute = path.join(folder, file)
        if (fs.statSync(absolute).isDirectory()) {
            return validateNoVariablesRemainInFolder(absolute, replacements)
        } else {
            return validateNoVariablesRemainInFile(absolute, replacements)
        }
    })

}

function validateNoVariablesRemainInFile(file, replacements) {
    // console.log(' validating file: ' + file)
    let result = fs.readFileSync(file, 'utf8')
    for (replacement of replacements) {
        let replacementString = '${' + replacement.name + '}'
        // console.log('  validating: ' + replacement.name)
        if (result.indexOf(replacementString) > -1) console.log('Found known variable: ' + replacementString + ' in file ' + file)
    }
    let randomVariables = result.match(/\${.*}/g)
    if (randomVariables) {
        for (replacement of replacements) {
            let replacementString = '${' + replacement.name + '}'

            let index = randomVariables.indexOf(replacementString)
            if (index > -1) {
                randomVariables.splice(index, 1)
            }
        }
    }
    if (randomVariables) console.log('Found unknown varibles ' + randomVariables + ' in file ' + file)
}

exports.replaceVariablesInFile = replaceVariablesInFile
exports.replaceVariablesInFolder = replaceVariablesInFolder
exports.validateNoVariablesRemainInFolder = validateNoVariablesRemainInFolder
exports.validateNoVariablesRemainInFile = validateNoVariablesRemainInFile