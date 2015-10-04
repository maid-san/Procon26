fs = require 'fs'
request = require 'request'

HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

###
getProblem = (url) =>
    request.get url, (error, response, body) =>
        console.log if !error && response.statusCode == 200 then \
        body else 'error : ' + response.statusCode
###

postAnswer = (host, token, file) =>
    option = 
        uri : 'http://' + host + '/answer'
        formData :
            token : token
            answer: fs.createReadStream(__dirname + '/Res/' + file)
    request.post option, (error, response, body) =>
        console.log body + '[System]Status : ' + response.statusCode
        
