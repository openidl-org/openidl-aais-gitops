"use strict";

const AWSXRay = require("aws-xray-sdk-core");
const AWS = AWSXRay.captureAWS(require("aws-sdk"));

const validator = require("./helpers/validators");
const responders = require("./helpers/responders");

const s3 = new AWS.S3();

/**
 * @since 1.0.0
 * @author Findlay Clarke
 * @description Gets a presigned url so that a file can be uploaded
 *
 * @param {string} event.body.filename The filename that is used to upload the file
 */
exports.handler = async (event, context, callback) => {
  console.log(JSON.stringify(event));

  const inputValid = validator.validateInput(
    event,
    callback,
    null,
    [["filename", "string"]]
  );
  if (!inputValid) return;

  const body = JSON.parse(event.body);
  let url;
  const date = new Date();
  const objectKey = `uploads/${date
    .toISOString()
    .substr(0, 4)}/${date.toISOString().substr(5, 2)}/${body.filename}`;

  try {
    const params = {
      Bucket: process.env.FILE_UPLOAD_BUCKET,
      Fields: {
        key: objectKey,
      },
      Expires: 120,
      //https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html
      Conditions: [
        ["content-length-range", 1, 5 * 1024 * 1000 * 1000], // 1 byte - 5GB
        ["starts-with", "$Content-Type", "text/plain"],
        ["eq", "$key", objectKey],
        ["eq", "$x-amz-meta-filename", body.filename],
      ],
    };
    console.log("calling getSignedUrl with params", JSON.stringify(params));
    url = s3.createPresignedPost(params);
    url.fields["x-amz-meta-filename"] = body.filename;

    console.log("The URL is", url);
  } catch (error) {
    console.error("Could not get url", error);
    return callback(
      null,
      responders.getNon2XX(500, "An error occured. Please try again later")
    );
  }

  return callback(null, responders.get2XX(url));
};
