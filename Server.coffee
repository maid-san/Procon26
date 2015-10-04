fs = require 'fs'
request = require 'request'
app = require('express')()

HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

hiscore = 0

postAnswer = (host, token, file) ->
    option = 
        uri : 'http://' + host + '/answer'
        formData :
            token : token
            answer: fs.createReadStream(__dirname + '/Res/' + file)
    request.post option, (error, response, body) ->
        console.log body + '[System]Status : ' + response.statusCode
        
app.post '/answer', (req, res) ->
    
    
app.get '/hiscore', (req, res) ->
    res.send hiscore + ''