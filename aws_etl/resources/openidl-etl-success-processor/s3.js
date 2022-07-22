const config = require("./config/config.json");
var aws = require("aws-sdk");
aws.config.update({ region: "us-east-2" });
const s3 = new aws.S3({ apiVersion: "2006-03-01" });
const ddb = new aws.DynamoDB({ apiVersion: "2012-08-10" });

const params = {
    Bucket: 'aais-dev-openidl-etl-idm-loader-bucket',
    Key: 'sample-data-9001.json'
  }



  async function home(){
    const raw = await s3.getObject(params).promise();
    const data = raw.Body.toString('utf-8')
    console.log('data: '+data)
  }

  home()