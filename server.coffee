request = require 'request'
host = 'testform26.procon-online.net'
token = '0123456789abcdef'
url = 'http://' + host + '/quest1.txt' + '?token=' + token

request.get url, (error, response, body) =>
    if !error && response.statusCode == 200
        console.log body
    else
        console.log 'error : ' + response.statusCode
