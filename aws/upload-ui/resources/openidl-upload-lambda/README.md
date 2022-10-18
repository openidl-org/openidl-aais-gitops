## Getting Started

- Install SAM CLI
  - https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html
- Run `sam build`
- Run `sam deploy --guided`
- Enter a valid email address when prompted and your temp password will be sent to you
  take note of the outputs and enter them in the `web-app` folder
  - `web-app/.env.development`
    - `REACT_APP_AMPLIFY_AUTH_USER_POOL_ID` = `CognitoID`
    - `REACT_APP_AMPLIFY_AUTH_USER_POOL_WEB_CLIENT_ID` = `CognitoClientID`
    - `REACT_APP_AMPLIFY_API_ENDPOINT_MDS_URL` = `ApiUrl`




