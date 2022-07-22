// const config = require("./config/config.json");
const source = require("./sample-data-9001.json")
const processRecords = require("../processor").process;
//console.log(source)

console.log('start')
async function process(){
    let response = await processRecords(source)

    //console.log(response)
    console.log(response['status'])
    
}

process()