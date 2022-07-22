const processRecords = require("./processor").process;

const config = require("./config/config.json");
var aws = require("aws-sdk");
aws.config.update({ region: "us-east-2" });
const s3 = new aws.S3({ apiVersion: "2006-03-01" });
const ddb = new aws.DynamoDB.DocumentClient();

function getParams(event) {
  // Get the object from the event and show its content type
 // console.log("event: ");
 // console.log(event['Records'])
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " ")
  );
  const params = {
    Bucket: bucket,
    Key: key,
  };
  return params;
}

async function updateStatus(key,status){

    let start = {
        TableName: config.Dynamo["etl-control-table"],
        Key: { 'SubmissionFileName': { S: key } },
        UpdateExpression: "set idmLoader = :st",
        ExpressionAttributeValues: {
            ":st": { S: status }
        },
        ReturnValues: "ALL_NEW"
      }

    await ddb.updateItem(start).promise()
}

async function setUp(eventParams){
    const params2 = {
        TableName: config["Dynamo"]["etl-control-table"],
        Key: { SubmissionFileName: eventParams.Key },
      };
      //console.log("params2 "+ params2);
      console.log('get item')
      let item = await ddb.get(params2).promise();
      console.log("item next");
      console.log(item.Item)
      if (item.SubmissionFileName) {
        console.log("file exists in control");
    
        if (!item.IDMLoaderStatus === "success") {
          console.log("record exists in control, but no idm success");
          updateStatus(eventParams.Key,'submitted')
          //make payload
        }
      }
      if (!item.SubmissionFileName) {
        console.log("file DNE in control");
        //add submitted record
        let insertParams = {
          TableName: config.dynamoDB.tableName,
          Item: {
            SubmissionFileName: { S: eventParams.Key },
            IDMLoaderStatus: { S: "submitted" },
          },
        };
        await ddb.putItem(insertParams).promise();
      }
}

async function getRecords(eventParams){
    console.log('get records, params: ')

    eventParams = {
        Bucket: 'aais-dev-openidl-etl-idm-loader-bucket',
        Key: 'sample-data-9001.json'
      }

    console.log(eventParams)
    const raw = await s3.getObject(eventParams).promise();
    const data = raw.Body.toString('utf-8')
    console.log('data: ')
    console.log(data)
    return data
}

exports.handler = async function (event, context) {
  // let recordsToLoad = []
  // event.Records.forEach(recordToLoad => {
  //     console.log("We have a new record");
  //     const { body } = record;
  //     recordsToLoad.push(JSON.parse(body))
  //     console.log(`ETL ID: ${JSON.parse(body).EtlID}`)
  //     console.log(body)
  // });

  //get file name

  let eventParams = getParams(event);
  //console.log("bucket: " + eventParams.Bucket + " key: " + eventParams.Key);

  await setUp(eventParams)
  
//   let records = getRecords(eventParams)

//   console.log('records: ')
//   for (let record of records) {
//     console.table(record)
//   }

  //make payload
  //submit payload
  //add new record

  //await processRecords(recordsToLoad)
  return {};
};
