/**
 * index.js
 * 
 * Process csv files from the s3 bucket that is the trigger
 * Put failures into the failure bucket described in the config.json file
 * Put successes into the idm loader bucket also described in the config.json file
 * @author Ken Sayers
 */
console.log('Loading function');

const aws = require('aws-sdk');

const s3 = new aws.S3({ apiVersion: '2006-03-01' });
const ddb = new aws.DynamoDB({ apiVersion: '2012-08-10' })

const convertToJson = require('./intake-to-json-processor').convertToJson
const SecretsManager = require('./SecretsManager.js');

const config = require('./config/config.json')

// Handle the s3.putObject event
exports.handler = async (event, context) => {
    //console.log('Received event:', JSON.stringify(event, null, 2));

    // Get the object from the event and show its content type
    const bucket = event.Records[0].s3.bucket.name;
    const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' ')).split('.')[0];
    const file_ext = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' ')).split('.')[1];

    const params = {
        Bucket: bucket,
        Key: key,
    };

    // Setup SNS parameters for success and failure
    try {
        var sns = new aws.SNS();
        var snsFailureParams = {
            Message: 'unknown',
            Subject: "ETL Intake Processing Has Failed",
            TopicArn: config.sns.failureTopicARN
        };
        var snsSuccessParams = {
            Message: 'unkknown',
            Subject: "ETL Intake Processing Has Succeeded",
            TopicArn: config.sns.successTopicARN
        };

        // check if already succeeded.  fail if so
        let dbParams = {
            TableName: config.dynamoDB.tableName,
            Key: { 'SubmissionFileName': { S: key } }
        }
        const item = await ddb.getItem(dbParams).promise()

        // if the status is already success, fail gracefully
        let result
        if (item && item.Item && (item.Item.IntakeStatus.S === 'success')) {
            snsFailureParams.Message = `the file ${key} has already been processed successfully`
            let snsResponse = await sns.publish(snsFailureParams).promise();
            console.log(snsResponse)
            throw new Error('file has already been processed successfully')
        }

        // setup an initial item for the file in the control db
        dbParams = {
            TableName: config.dynamoDB.tableName,
            Item: { 'SubmissionFileName': { S: key }, 'IntakeStatus': { S: 'submitted' } }
        }
        const insertResult = await ddb.putItem(dbParams).promise()
        const getParams = {'Bucket': params.Bucket, 'Key': params.Key+'.'+file_ext}
        console.log('get params: '+getParams)
        const data = await s3.getObject(getParams).promise();

        // get the csv data and convert it into a json file
        if (!result) result = await convertToJson(data.Body.toString())
        if (result.valid) {

            // register success in control db, put result into s3 and send message
            let s3Result = await s3.putObject({ Bucket: config.successBucket.name, Key: key + '.json', Body: JSON.stringify(result.records) }).promise();

            dbParams = {
                TableName: config.dynamoDB.tableName,
                Key: { 'SubmissionFileName': { S: key } },
                UpdateExpression: "set IntakeStatus = :st",
                ExpressionAttributeValues: {
                    ":st": { S: 'success' }
                },
                ReturnValues: "ALL_NEW"
            }
            const updateResult = await ddb.updateItem(dbParams).promise()
            snsSuccessParams.Message = `The file ${key} has been processed successfully`
            let snsResponse = await sns.publish(snsSuccessParams).promise();
            return JSON.stringify(s3Result)
        } else {

            // register failure in control db, put result into failure s3 and send message
            let s3Result = await s3.putObject({ Bucket: config.failureBucket.name, Key: key + '-failure.json', Body: JSON.stringify(result) }).promise();

            dbParams = {
                TableName: config.dynamoDB.tableName,
                Key: { 'SubmissionFileName': { S: key } },
                UpdateExpression: "set IntakeStatus = :st",
                ExpressionAttributeValues: {
                    ":st": { S: 'failure' }
                },
                ReturnValues: "ALL_NEW"
            }
            const updateResult = await ddb.updateItem(dbParams).promise()
            snsFailureParams.Message = `The file ${key}.${file_ext} has failed processing`
            let snsResponse = await sns.publish(snsFailureParams).promise();
            return JSON.stringify(s3Result)
        }
    } catch (err) {
        console.log(err);
        const message = `Error processing ${key} from bucket ${bucket}. Error: ${err}`;
        console.log(message);
        throw new Error(message);
    }
};