const csv = require('csvtojson')
const DateTime = require('luxon').DateTime
const config = require('./config/config.json')

async function convertToJson(recordsText) {
    // let textRecords = recordsText.split('\n')
    let errors = []
    await csv()
        .on('error', (err) => {
            errors.push({ 'type': 'csv parsing', 'message': err })
        })
        .fromString(recordsText)
        .then((jsonObj) => {
            outputRecords = jsonObj
        })

    if (errors.length > 0) {
        return { 'valid': false, 'errors': errors }
    }
    if (outputRecords.length === 0) {
        return { 'valid': false, 'errors': [{ 'type': 'data', 'message': 'empty data' }] }
    }
    let resultRecords = []
    for (outputRecord of outputRecords) {
        let resultRecord = {}
        let recordError = false
        resultRecord.carrierNumber = outputRecord['Carrier Number']
        resultRecord.state = outputRecord['State']
        if (!resultRecord.state) {
            resultRecord.state = config.state
        }
        resultRecord.vin = outputRecord['VIN']
        let txDate = DateTime.fromSQL(outputRecord['Transaction Date'])
        resultRecord.transactionDate = txDate.toISODate()
        // console.log(`Transaction Date ${txDate}`)
        let effDate = DateTime.fromSQL(outputRecord['Effective Date'])
        if (!effDate.isValid) {
            effDate = txDate
        }
        resultRecord.effectiveDate = effDate.toISODate()
        // console.log(`Effective Date ${effDate}`)
        let expDate = DateTime.fromSQL(outputRecord['Expiration Date'])
        if (!expDate.isValid) {
            expDate = txDate.plus({ months: 1 })
        }
        resultRecord.expirationDate = expDate.toISODate()
        if (!resultRecord.carrierNumber) {
            errors.push({ 'type': 'data', 'message': 'missing carrier number', 'record': outputRecord })
            recordError = true
        }
        if (!resultRecord.vin) {
            errors.push({ 'type': 'data', 'message': 'missing vin', 'record': outputRecord })
            recordError = true
        }
        if (!resultRecord.transactionDate) {
            errors.push({ 'type': 'data', 'message': 'missing transaction date', 'record': outputRecord })
            recordError = true
        }
        if (!resultRecord.effectiveDate) {
            errors.push({ 'type': 'data', 'message': 'missing effective date', 'record': outputRecord })
            recordError = true
        }
        if (!resultRecord.expirationDate) {
            errors.push({ 'type': 'data', 'message': 'missing expiration date', 'record': outputRecord })
            recordError = true
        }
        if (!recordError) resultRecords.push(resultRecord)
    }
    if (errors.length > 0) {
        return { 'valid': false, 'errors': errors }
    }
    return { 'valid': true, 'records': resultRecords }
}

module.exports.convertToJson = convertToJson