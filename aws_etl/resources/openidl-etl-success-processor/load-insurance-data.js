const getCredentials = require('./secrets-utility').getCredentials
const login = require('./api-helper').login
const buildURL = require('./api-helper').buildURL
const fetch = require('node-fetch');
const fs = require('fs')
const config = require('./config/config.json');
const { toUnicode } = require('punycode');

module.exports.buildPayload = function (records) {
    let payload = {
        "records": [],
        "sourceId": config.sourceId,
        "batchId": config.batchId,
        "chunkId": config.chunkId,
        //"carrierId": records[0].Policy.CompanyID,
        "carrierId": '5',
        "policyNo": "91111111",
        "errFlg": false,
        "errrLst": [],
        "SquenceNum": 1001,
        "_id": "9sample"
    }
    for (record of records) {
        record.chunkId = config.chunkId
        record.chunkid = config.chunkId
        // console.log('new record')
        // console.log(JSON.stringify(record))
        payload.records.push(record)
    }
    return payload;
}
async function callAPI(apiUrl, payload, token) {
    console.log('call api for IDM')
    try {
        //console.log("Calling API with batch: ", payload.batchId)
        //console.log('token: '+token)
        //console.log('api url: '+apiUrl)
        //console.log(payload)
        let response = await fetch(apiUrl + "openidl/api/load-insurance-data", {
            method: "POST",
            headers: {
                "Accept": "application/json",
                "Content-Type": "application/json",
                "Authorization": "Bearer " + token,
            },
            body: JSON.stringify(payload),
        });
        // if (response.status !== 200) {
        //     console.log(response)
        //     if (response.status !== 504) {
        //         process.exit(0)
        //     }
        // }
        console.log('after idm response')
        console.log(response)
        return response
    } catch (error) {
        console.log("Error with post of insurance data " + error);
        return;
    }
}

async function writeInsuranceDataToFileSystem(payload) {
    fs.writeFileSync('payload.json', JSON.stringify(payload))
}


let commandArgs = process.argv.slice(2)
let dryRunArg = commandArgs[0]
let dryRun = (dryRunArg && (dryRunArg === 'dry-run' || dryRunArg === 'true'))

console.log(commandArgs)
console.log('dryRun: ' + dryRun)

module.exports.loadInsuranceData = async function (records) {
    console.log("Inside process records.  " + records.length + " records.")
    let baseURL = buildURL(config, 'carrier', 'utilities')
    console.log(`Logging in`)
    // let credentials = await getCredentials()
    let userToken = await login(baseURL, config.username, config.password)
    console.log(`Status: ${userToken.status}`)
    if (userToken.status == 200){
        baseURL = buildURL(config, 'carrier', 'insurance-data-manager')
        // console.log(JSON.stringify(dataToLoad))
        let payload = module.exports.buildPayload(records)
        console.log('load insurance 79')
        let response = await callAPI(baseURL, payload, userToken.token)
        return response
    }
    const status = {'status': userToken.status}
    return status
    

}
