"use strict";

/**
 * @author Findlay Clarke
 * @since 1.0.0
 * @description This function allows the API to be called when Authorization header is set.
 * The reason why this is needed is because when the Authorization header is set
 * Browser preflight (OPTIONS) call fails if the origin is "*". You must specify
 * the origin as a single domain. For more details see
 * https://serverless.com/blog/cors-api-gateway-survival-guide/
 */
exports.handler = (event, context, callback) => {
  //By default allow all origins
  let origin = "*";

  console.log(JSON.stringify(event));

  if (event.headers && event.headers.origin && process.env.ALLOWED_ORIGINS) {
    const isOriginAllowed = process.env.ALLOWED_ORIGINS.split(",").includes(
      event.headers.origin
    );

    if (isOriginAllowed) {
      origin = event.headers.origin;
    } else {
      console.log(
        "Getting called from a location that is not in the allowed list",
        "process.env.ALLOWED_ORIGINS [",
        process.env.ALLOWED_ORIGINS,
        "]"
      );
    }
  }

  const response = {
    statusCode: 200,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": origin,
      "Access-Control-Allow-Credentials": true,
      "Access-Control-Allow-Headers": "Content-Type, Authorization, Origin",
      "Access-Control-Allow-Methods": "GET, PUT, POST, DELETE, PATCH",
      "Access-Control-Max-Age": 600, //chrome limit is 10 mins
    },
  };

  console.log(JSON.stringify(response));

  return callback(null, response);
};
