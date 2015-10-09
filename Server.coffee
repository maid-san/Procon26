fs = require 'fs'
moment = require 'moment'
multer = require 'multer'
request = require 'request'
program = require 'commander'
bodyParser = require 'body-parser'

app = require('express')()
sleep  = require('sleep-async')()
upload = multer dest: 'uploads/'

app.use bodyParser.json extended: true
app.use bodyParser.urlencoded extended: true

#演習用
HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

###本番用
HOST  = '172.16.1.2'
TOKEN = '????????????????'
###

program
  .version '1.0.0'
  .option  '-p, --port <n>', 'designate number of port releasing', 40000
  .parse   process.argv

bestscore = 1024
timeLastPosted = moment()

isBestscore = (score, bestscore) ->
  return score < bestscore
        
latency = (before, after) ->
  return if after - before > 1000 then 0 else 1000 - after + before
        
app.post '/answer', upload.single('answer'), (req, res) ->
  timeNewPosted = moment()
  response =
    isBestscore: isBestscore req.body.score, bestscore
    latency: latency timeLastPosted, timeNewPosted
  res.send response
  console.log response
  console.log "token: #{req.body.token}"
  console.log "score: #{req.body.score}"
  console.log 'answer: ', req.file

  if response.isBestscore
    console.log '[System]Meu Score!'
    bestscore = req.body.score
    timeLastPosted = timeNewPosted
    sleep.sleep response.latency, () ->
      option =
        uri : "http://#{HOST}/answer"
        formData :
          token : TOKEN
          answer: fs.createReadStream("#{__dirname}/#{req.file.path}")
      request.post option, (err, res, body) ->
        console.log body
        score = body.split("\r\n")[1].split(' ')[1]
        if score != req.body.score
          console.log '[System] Request score is wrong...'
          bestscore = score

app.get '/bestscore', (req, res) ->
  res.send bestscore : bestscore
  
app.get '/quest', (req, res) ->
  uri = "http://#{HOST}/quest#{req.query.num}.txt?token=#{TOKEN}"
  request uri, (error, response, body) ->
    if !error && response.statusCode == 200
      console.log body
      res.send body
    else
      console.log 'error : ' + response.statusCode

app.listen program.port, () ->
  console.log "Running *:#{program.port}"
