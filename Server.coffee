fs = require 'fs'
moment = require 'moment'
multer = require 'multer'
app = require('express')()
request = require 'request'
bodyParser = require 'body-parser'

HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

bestscore = 1000000
time = moment()

#app.use multer dest: './uploads/'
app.use bodyParser.json extended: true
app.use bodyParser.urlencoded extended: true

postAnswer = (host, token, file) ->
    option = 
        uri : 'http://' + host + '/answer'
        formData :
            token : token
            answer: fs.createReadStream(file)
    request.post option, (error, response, body) ->
        console.log body + '[System]Status : ' + response.statusCode

isBestscore = (score, bestscore) ->
    return score < bestscore
        
passOneSecond = (before, after) ->
    return after - before > 1000
        
app.post '/answer', (req, res) ->
    console.log 'bestscore: ' + bestscore
    response = 
        isBestscore:   isBestscore req.body.score, bestscore
        #passOneSecond: passOneSecond time, moment()
    res.send response
    console.log response
    console.log 'score: ' + req.body.score
    #console.log 'ans: ' + req.files
    if response.isBestscore
        console.log '[System]The new Best Score!'
        bestscore = req.body.score 
    #console.log req.body
    
app.get '/bestscore', (req, res) ->
    res.send bestscore : bestscore + ''    

app.listen process.argv[2]
