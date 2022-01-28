// the input file name is passed in with full path
// the output file name is also passed in with full path

const fs = require('fs')

let args = process.argv.slice(2)

let inputText = fs.readFileSync(args[0], 'utf-8')
console.log(inputText)
let inputJson = JSON.parse(inputText)

fs.writeFileSync(args[1], JSON.stringify(inputJson.data.data))