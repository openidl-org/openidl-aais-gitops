const AWS = require('aws-sdk');
exports.handler = async (event, context, callback) => {
    if(event.triggerSource === "CustomMessage_AdminCreateUser") {
        console.log("Event: %j", event);
        const cognitoidentityserviceprovider = new AWS.CognitoIdentityServiceProvider(
            {
                apiVersion: '2016-04-18',
                region: event.region
            });
        var params = {
            UserPoolId: event.userPoolId
        };
        const data = await cognitoidentityserviceprovider.listUserPoolClients(params).promise();
        var clientId;
        data.UserPoolClients.forEach(element => {
            if (element.ClientName === process.env.APP_CLIENT_NAME){
                clientId = element.ClientId;
            }     
        });
        console.log("Client ID is " + clientId);
        // Ensure that your message contains event.request.codeParameter event.request.usernameParameter. This is the placeholder for the code and username that will be sent to your user.
        event.response.smsMessage = "Welcome to the service. Your user name is " + event.request.usernameParameter + " Your temporary password is " + event.request.codeParameter;
        event.response.emailSubject = "Welcome to Identifying Vehicles with Personal Line Auto Coverage Data Call";
        event.response.emailMessage = "The link below will allow you to change your password. You will be able to use these credentials for the data call and upload user interfaces. <br /><br />Your user name is " + event.request.usernameParameter + " Your temporary password is " + event.request.codeParameter +". <br><br /><b>Reset Password:</b> <a href=\"https://" + process.env.COGNITO_DOMAIN + ".auth." + event.region + ".amazoncognito.com/login?client_id=" + clientId + "&response_type=code&scope=aws.cognito.signin.user.admin+email+openid+phone+profile&redirect_uri=" + process.env.REDIRECT_URI + "\">LINK</a>";
    }
    callback(null, event);
};