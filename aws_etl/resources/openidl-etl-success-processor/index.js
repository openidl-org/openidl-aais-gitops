const processRecords = require("./processor").process;

const config = require("./config/config.json");
var aws = require("aws-sdk");
aws.config.update({ region: "us-east-2" });
const s3 = new aws.S3({ apiVersion: "2006-03-01" });
const ddb = new aws.DynamoDB.DocumentClient();
var sns = new aws.SNS();

function getParams(event) {
  // Get the object from the event and show its content type
  // console.log("event: ");
  // console.log(event['Records'])
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " ").split(".")[0]
  );
  const file_name = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " ")
  );

  const params = {
    Bucket: bucket,
    Key: key,
    FileName: file_name,
  };
  return params;
}

async function setUp(eventParams) {
  let run = false;
  const params2 = {
    TableName: config.Dynamo.etlControlTable,
    Key: { SubmissionFileName: eventParams.Key },
  };
  console.log("params2");
  console.log(params2);
  console.log("get item");
  let item = await ddb.get(params2).promise();
  console.log("item next");
  console.log(item.Item);
  if (item.Item) {
    if (item.Item.SubmissionFileName === eventParams.Key) {
      console.log("file exists in control");

      if (item.Item.IDMLoaderStatus === "success") {
        run = false;
        console.log("file found status: sucesss");
        //sns file has already been loaded
        var snsFailureParams = {
          Message: eventParams.Key + " has already been loaded to IDM",
          Subject: "ETL Loader Processing Has Failed",
          TopicArn: config.sns.failureETLARN,
        };
        await sns.publish(snsFailureParams).promise();
      }

      if (item.Item.IDMLoaderStatus === "submitted") {
        run = false;
        console.log("file found status: submitted");
        //sns file is already processing

        var snsFailureParams = {
          Message: eventParams.Key + " is already processing/hung",
          Subject: "ETL Loader Processing Has Failed",
          TopicArn: config.sns.failureETLARN,
        };
        await sns.publish(snsFailureParams).promise();
      }

      if (item.Item.IDMLoaderStatus === "error") {
        run = true;
        console.log("file found status: error");
      }

      if (item.Item.IDMLoaderStatus === "") {
        run = true;
        console.log("file found status: blank");
      }

      if (!item.Item.IDMLoaderStatus) {
        run = true;
        console.log("No Loader Record found");
      }
    }

    if (!item.Item.IntakeStatus === "success") {
      run = false;
      console.log("Loader error: File Has already been loaded");
    }

    //add submitted record
    if (run) {
      let insertParams = {
        TableName: config.Dynamo.etlControlTable,
        Item: {
          SubmissionFileName: eventParams.Key,
          IntakeStatus: "success",
          IDMLoaderStatus: "submitted",
        },
      };
      await ddb.put(insertParams).promise();
    }
    return run;
  }

  let insertParams = {
    TableName: config.Dynamo.etlControlTable,
    Item: {
      SubmissionFileName: eventParams.Key,
      IntakeStatus: "Not Found",
      IDMLoaderStatus: "error",
    },
  };
  await ddb.put(insertParams).promise();

  return false;
}

async function getRecords(eventParams) {
  // console.log('get records, params: ')
  // console.log(eventParams)
  const params = { "Bucket": eventParams.Bucket, "Key": eventParams.FileName };
  console.log('get records params :')
  console.log(params)
  const raw = await s3.getObject(params).promise();
  const data = JSON.parse(raw.Body.toString("utf-8"));
  // console.log('data: ')
  // console.log(data)
  return data;
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
  console.log(
    "bucket: " + eventParams.Bucket + " key: " + eventParams.FileName
  );

  let run = await setUp(eventParams);
  console.log("Send Payload: " + run);

  if (run) {
    let recordsToLoad = await getRecords(eventParams);
    console.log("records length: " + recordsToLoad.length);
    console.log(recordsToLoad);
    let response = await processRecords(recordsToLoad);
    const status = response["status"];
    console.log("response status: " + status);

    if (status == "200") {
      //success
      let insertParams = {
        TableName: config.Dynamo.etlControlTable,
        Item: {
          SubmissionFileName: eventParams.Key,
          IntakeStatus: "success",
          IDMLoaderStatus: "success",
        },
      };
      await ddb.put(insertParams).promise();
      var snsSuccessParams = {
        Message: eventParams.Key + " is loaded to IDM",
        Subject: "ETL Loader Processing Has Succeeded",
        TopicArn: config.sns.successETLARN,
      };
      await sns.publish(snsSuccessParams).promise();
    } else {
      let insertParams = {
        TableName: config.Dynamo.etlControlTable,
        Item: {
          SubmissionFileName: eventParams.Key,
          IntakeStatus: "error on IDM load",
          IDMLoaderStatus: "error",
        },
      };
      await ddb.put(insertParams).promise();
      var snsFailureParams = {
        Message: eventParams.Key + " failed to load IDM",
        Subject: "ETL Loader Processing Has Failed",
        TopicArn: config.sns.failureETLARN,
      };
      await sns.publish(snsFailureParams).promise();
    }
  } else {
    console.log(" This file failed to load\n it has prior success/mid processing/no intake status");
  }

  //make payload
  //submit payload
  //add new record

  //await processRecords(recordsToLoad)
  return {};
};
