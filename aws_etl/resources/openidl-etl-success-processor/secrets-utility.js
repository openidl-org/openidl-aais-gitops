// Use this code snippet in your app.
// If you need more information about configurations or implementing the sample code, visit the AWS docs:
// https://aws.amazon.com/developers/getting-started/nodejs/

// Load the AWS SDK
const AWS = require('aws-sdk')
const { SecretsManagerClient, GetSecretValueCommand } = require("@aws-sdk/client-secrets-manager");


module.exports.getCredentials = async function () {
    let region = "us-east-1",
        secretName = "<org name>/dev/user/admin",
        decodedBinarySecret;

    const client = new SecretsManagerClient({
        region: region
    })
    const command = new GetSecretValueCommand({ SecretId: secretName })

    // In this sample we only handle the specific exceptions for the 'GetSecretValue' API.
    // See https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
    // We rethrow the exception by default.

    let secret = await client.send(command)


    return JSON.parse(secret.SecretString)
}