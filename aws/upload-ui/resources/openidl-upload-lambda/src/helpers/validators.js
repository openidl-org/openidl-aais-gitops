"use strict";

const responders = require("./responders");

/**
 * @since 1.0.0
 * @author Findlay Clarke <findlayc@aaisonline.com>
 * @public
 *
 * @description Validates the input. Warning booleans cannot be tested for its truthyness.
 *
 * Validates input generically for incoming data from the outside world. This has been tailored
 * specifically for AWS lambda.
 *
 * @param {*} event The event that is passed in th lambda function
 * @param {*} callback the callback to terminate the lambda function early if needed
 * @param {[]} [pathParameters = []] An optional array of key value pairs where the key is the path
 * parameter name and the value is the data type. Example [["customerId", "string"], ["userId", "string"]].
 * @param {[]} [bodyParameters= []] An optional array of key value pairs where the key is the body
 * @param {[]} [queryStringParameters= []] An optional array of key value pairs where the key is the query string
 * parameter name and the value is the data type. Example [[userId: "string"], ["orgId", "string"]
 * @returns {Boolean} Returns true if the data is valid. false if the input is invalid
 */
exports.validateInput = (
  event,
  callback,
  pathParameters = undefined,
  bodyParameters = undefined,
  queryStringParameters = undefined
) => {
  //this does not print binary data in the logs
  console.log(
    "Validating input. event:",
    JSON.stringify(event, (key, value) => {
      if (key === "body") {
        try {
          const modifiedBody = JSON.parse(value);
          if (modifiedBody && modifiedBody.imageInBase64) {
            modifiedBody.imageInBase64 =
              "base64 data will not print in the logs to save space";
          }
          return modifiedBody;
        } catch (error) {
          //do nothing here
        }
      }
      return value;
    })
  );

  if (!event) {
    console.error(
      "Input validation failed. Expecting an event which was not passed in"
    );

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      "The passed in event is not populated"
    );
    callback(null, response);

    return false;
  }

  const pathParametersValid = validatePathParameters(
    event,
    callback,
    pathParameters
  );

  if (!pathParametersValid) return false;

  const bodyParametersValid = validateBodyParameters(
    event,
    callback,
    bodyParameters
  );
  if (!bodyParametersValid) return false;

  const queryStringParametersValid = validateQueryStringParameters(
    event,
    callback,
    queryStringParameters
  );
  if (!queryStringParametersValid) return false;

  console.log("Input validation completed successfully");
  return true;
};

/**
 * @private
 * @param {Object} event
 * @param {*} callback
 * @param {*} pathParameters
 *
 * @returns {Boolean} `true` if the data is valid. `false` if the data is invalid
 */
function validatePathParameters(event, callback, pathParameters = []) {
  //check for nulls or undefined to default just in case the caller forgets
  if (!pathParameters) {
    return true;
  }

  if (!Array.isArray(pathParameters)) {
    console.error(
      "Optional pathParameter that is passed to this method are not arrays as expected."
    );

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      "The passed in path parameter is not in the expected format"
    );
    callback(null, response);

    return false;
  }

  console.log(
    "Starting to validate all pathParameters:",
    JSON.stringify(pathParameters)
  );

  /**
   * Go over the path parameters and check that they are valid
   */
  for (const [pathParameterName, pathParameterType] of new Map(
    pathParameters
  )) {
    console.log(
      `Checking for required path parameter [${pathParameterName}] is of type [${pathParameterType}]`
    );

    //validate that we are not checking for booleans
    if (
      pathParameterType === "boolean" ||
      pathParameterType === "object" ||
      pathParameterType === "function" ||
      pathParameterType === "undefined"
    ) {
      console.error(
        `Cannot validate truthiness for 'boolean', 'object', 'function' or 'undefined' types. Please handle validating [${pathParameterName}] outside this function`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Cannot validate pathParameter [${pathParameterName}]`
      );
      callback(null, response);
      return false;
    }

    if (
      !event.pathParameters[pathParameterName] ||
      typeof event.pathParameters[pathParameterName] !== pathParameterType
    ) {
      console.error(
        `Path Validation failed. Parameter [${pathParameterName}] is set to [${
          event.pathParameters[pathParameterName]
        }] and expected type [${pathParameterType}] but received [${typeof event
          .pathParameters[pathParameterName]}]`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Cannot validate [${pathParameterName}]. Check that the pathParameter [${pathParameterName}] is a [${pathParameterType}]`
      );
      callback(null, response);

      return false;
    }
  }

  console.log(
    "Successfully validated all pathParameters:",
    JSON.stringify(pathParameters)
  );

  return true;
}

/**
 * @private
 * @param {Object} event
 * @param {Object} callback
 * @param {Object} pathParameters
 *
 * @returns {Boolean} `true` if the data is valid. `false` if the data is invalid
 */
function validateBodyParameters(event, callback, bodyParameters = undefined) {
  if (!bodyParameters) {
    return true;
  }

  if (!Array.isArray(bodyParameters)) {
    console.error(
      "Optional bodyParameter that is passed to this method are not arrays as expected."
    );

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      "The passed in body parameter is not in the expected format"
    );
    callback(null, response);
    return false;
  }

  console.log(
    "Starting to validate all body parameters: ",
    JSON.stringify(bodyParameters)
  );

  if (bodyParameters.length > 0 && (!event.body || event.body.length <= 0)) {
    console.error(
      "Body parameters need to be checked but the required fields were not passed in they body"
    );

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      `Cannot validate required body params ${JSON.stringify(bodyParameters)}`
    );
    callback(null, response);

    return false;
  }
  let data = null;

  try {
    data = JSON.parse(event.body);
  } catch (error) {
    console.error("Error parsing the body", error);

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      `The required body does not seem to be valid JSON`
    );
    callback(null, response);

    return false;
  }

  /**
   * Go over the body parameters and check that they are valid
   */
  for (const [bodyParameterName, bodyParameterType] of new Map(
    bodyParameters
  )) {
    console.log(
      `Checking for required body parameter [${bodyParameterName}] is of type [${bodyParameterType}]`
    );

    //validate cannot check for certain types
    if (
      bodyParameterType === "object" ||
      bodyParameterType === "function" ||
      bodyParameterType === "undefined"
    ) {
      console.error(
        `Cannot validate truthiness for 'boolean', 'object', 'function' or 'undefined' types. Please handle validating [${bodyParameterName}] outside this function`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Cannot validate [${bodyParameterName}]`
      );
      callback(null, response);

      return false;
    }

    if (
      data[bodyParameterName] === "" ||
      data[bodyParameterName] === undefined ||
      typeof data[bodyParameterName] !== bodyParameterType
    ) {
      console.error(
        `Body Validation failed. Body parameter [${bodyParameterName}] is set to [${
          data[bodyParameterName]
        }] and expected type [${bodyParameterType}] but received [${typeof data[
          bodyParameterName
        ]}]`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Check that the body has [${bodyParameterName}] and is a [${bodyParameterType}]`
      );
      callback(null, response);

      return false;
    }
  }

  console.log(
    "Successfully validated all body parameters: ",
    JSON.stringify(bodyParameters)
  );

  return true;
}

/**
 * @private
 * @param {Object} event
 * @param {Object} callback
 * @param {Object} pathParameters
 *
 * @returns {Boolean} `true` if the data is valid. `false` if the data is invalid
 */
function validateQueryStringParameters(
  event,
  callback,
  queryStringParameters = undefined
) {
  if (!queryStringParameters) {
    return true;
  }

  if (!Array.isArray(queryStringParameters)) {
    console.error(
      "Optional queryStringParameter that is passed to this method are not arrays as expected."
    );

    const response = responders.getNon2XX(
      400,
      "Couldn't process the request.",
      `The passed in query string parameter ${JSON.stringify(
        queryStringParameters
      )} is not in the expected format`
    );
    callback(null, response);
    return false;
  }

  console.log(
    "Starting to validate all query string parameters: ",
    JSON.stringify(queryStringParameters)
  );

  if (!event.queryStringParameters) {
    console.log("Optional Query string parameters were not passed in");

    return true;
  }
  /**
   * Go over the queryStringParameters parameters and check that they are valid
   */
  for (const [queryStringParameterName, queryStringParameterType] of new Map(
    queryStringParameters
  )) {
    console.log(
      `Checking for optional query string parameter [${queryStringParameterName}] is of type [${queryStringParameterType}]`
    );

    //validate cannot check for certain types
    if (
      queryStringParameterType === "boolean" ||
      queryStringParameterType === "object" ||
      queryStringParameterType === "function" ||
      queryStringParameterType === "undefined"
    ) {
      console.error(
        `Cannot validate truthiness for 'boolean', 'object', 'function' or 'undefined' types. Please handle validating [${queryStringParameterName}] outside this function`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Cannot validate [${queryStringParameterName}]`
      );
      callback(null, response);

      return false;
    }

    if (
      event.queryStringParameters[queryStringParameterName] &&
      typeof event.queryStringParameters[queryStringParameterName] !==
        queryStringParameterType
    ) {
      console.error(
        `Query String Parameter Validation failed. Query string parameter [${queryStringParameterName}] is set to [${
          event.queryStringParameters[queryStringParameterName]
        }] and expected type [${queryStringParameterType}] but received [${typeof event
          .queryStringParameters[queryStringParameterName]}]`
      );

      const response = responders.getNon2XX(
        400,
        "Couldn't process the request.",
        `Check that the query string parameter has [${queryStringParameterName}] and is a [${queryStringParameterType}]`
      );
      callback(null, response);

      return false;
    }
  }

  console.log(
    "Successfully validated all query string parameters parameters: ",
    JSON.stringify(queryStringParameters)
  );

  return true;
}
