const loadInsuranceData = require('./load-insurance-data').loadInsuranceData

exports.process = async function (records) {
    console.log("Calling insurance data manager")
    await loadInsuranceData(records)
    return {}
}