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

HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

program
  .version '1.0.0'
  .option  '-p, --port <n>', 'designate number of port releasing', 40000
  .parse   process.argv

bestscore = 1000000000 #正の無限大
timeLastPosted = moment()

postAnswer = (host, token, file) ->
  option =
    uri : "http://#{host}/answer"
    formData :
      token : token
      answer: fs.createReadStream(file)
  request.post option, (err, res, body) ->
    console.log "[System]Status : #{res.statusCode}"
    console.log body

isBestscore = (score, bestscore) ->
  return score < bestscore
        
passOneSecond = (before, after) ->
  return if after - before > 1000 then 0 else after - before
        
app.post '/answer', upload.single('ans'), (req, res) ->
  console.log "bestscore: #{bestscore}"
  timeNewPosted = moment()
  console.log timeNewPosted - timeLastPosted
  response =
    isBestscore:   isBestscore req.body.score, bestscore
    passOneSecond: passOneSecond timeLastPosted, timeNewPosted
  res.send response
  console.log response
  console.log "score: #{req.body.score}"
  console.log 'ans: ', req.file

  if response.isBestscore
    console.log '[System]The new Best Score!'
    bestscore = req.body.score
    sleep.sleep response.passOneSecond, () ->
      postAnswer HOST, TOKEN, "#{__dirname}/#{req.file.path}"
    timeLastPosted = timeNewPosted

app.get '/bestscore', (req, res) ->
  res.send bestscore : bestscore + ''

app.listen program.port, () ->
  console.log "Running *:#{program.port}"
