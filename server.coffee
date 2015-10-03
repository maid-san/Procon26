request = require 'request'
url = '172.16.1.2'

request url, (error, response, body) =>
    if !error && response.statusCode == 200
        console.log JSON.parse(bode).name
    else
        console.log 'error : ' + response.statusCode
