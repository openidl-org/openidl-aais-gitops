/**
 * This will generate a response that are standard and
 * consistent across the application
 * @author Findlay Clarke <findlayc@aaisonline.com>
 * @since 1.0
 */
"use strict";

const { v4: uuid } = require("uuid");

/**
 * @desciption Gets a generic 2XX type success reponse
 *
 * @since 1.0
 * @public
 *
 * @param {Object} [body=undefined] the body that will be sent along with the response
 * @param {number} [statusCode=200] the status code that will be sent back to the caller
 */
exports.get2XX = (body = undefined, statusCode = 200) => {
  return exports.getCustom2XX(body, statusCode);
};

/**
 * @description Gets a non 200 status code that standardizes the error message back to the caller.
 * This helps the consumer to both have the ability to show a `friendlyErrorMessage`
 * to the user while still allowing a `technicalErrorMessage` to be sent over
 * for additional troubleshooting information. An `errorId` is also
 * generated to help identify and track down errors when searching the logs
 * to guarantee that the error is the same
 *
 * @since 1.0
 * @public
 *
 * @param {number} statusCode
 * @param {string} friendlyErrorMessage
 * @param {string} technicalErrorMessage
 * @returns {Object} The response object for generic success
 */
exports.getNon2XX = (
  statusCode = 500,
  friendlyErrorMessage = "Something went wrong",
  technicalErrorMessage = "Something went wrong"
) => {
  const body = {
    friendlyErrorMessage: friendlyErrorMessage,
    technicalErrorMessage: technicalErrorMessage,
    statusCode: statusCode,
    errorId: `error-id-${uuid()}`,
  };
  return exports.getCustom2XX(body, statusCode);
};

/**
 * @description Gets a generic 2XX style response that is standard. It also handles automatic
 * logging so the caller does not need to standardize on logging.
 * 
 * @since 1.0
 * @public
 * 
 * @param {Object} [body=undefined] This is the data that needs to be sent back to the 
 * caller. This should be a regular JSON object and will be converted to string
 * automatically if the `Content-Type` header is set to `application/json`. Otherwise
 * the body will be untouched
 * @param {number} [statusCode=200] The HTTP status code that will be sent back to
 * the caller
 * @param {Object} [additionalHeaders={}] any additional parameter you would like to send
 * over in addition to the `headers` parameter. The `additionalHeader` parameter will
 * overwrite the `headers` param if they have the same keys
 * @param {Object} [headers={
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "*",
    "Access-Control-Max-Age": 600
  }] The headers that will be used and set along with this reponse.
 */
exports.getCustom2XX = (
  body = undefined,
  statusCode = 200,
  additionalHeaders = {},
  headers = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Credentials": true,
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Methods": "*",
    "Access-Control-Max-Age": 600, //chrome limit is 10 mins
  }
) => {
  const mergedHeader = { ...headers, ...additionalHeaders };
  const response = {
    statusCode: statusCode,
    headers: mergedHeader,
  };

  if (body) {
    if (response.headers["Content-Type"] === "application/json") {
      response.body = JSON.stringify(body);
    } else {
      response.body = body;
    }
  }

  console.log("Generated a response: ", JSON.stringify(response));
  return response;
};
