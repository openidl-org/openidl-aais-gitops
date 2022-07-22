const fetch = require('node-fetch').default;

module.exports.login = async (baseURL, username, password) => {
    console.log("Inside login")
    try {
        let fullUrl = baseURL + "openidl/api/app-user-login"
        console.log("About to send fetch from " + fullUrl)
        let response = await fetch(fullUrl, {
            method: "POST",
            headers: {
                "Accept": "application/json",
                "Content-Type": "application/json",
            },
            body: JSON.stringify({ "username": username, "password": password }),
        });

        console.log('Response Status: '+response.status)
        if (response.status !== 200) {
            console.log('Error on login.')
            //console.log(response)
            // if (response.status !== 504) {
            //     process.exit(0)
            // }
            
            return response
        }
        result = await response.json()
        let userToken = {"token": result.result.userToken, "status": 200}
        //console.log('token: '+userToken)
        return userToken
    } catch (error) {
        console.log("Error with login " + error);
        return;
    }
}

module.exports.buildURL = (config, nodeName, service) => {
    return `http://${config[nodeName][service].url}/`

}

