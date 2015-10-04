fs = require 'fs'
moment = require 'moment'
multer = require 'multer'
express = require 'express'
request = require 'request'
bodyParser = require 'body-parser'

app = express()
upload = multer dest: 'uploads/'

app.use bodyParser.json extended: true
app.use bodyParser.urlencoded extended: true

HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

bestscore = 100000000 #正の無限大
post_time = moment()

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
  return after - before > 1000
        
app.post '/answer', upload.single('ans'), (req, res) ->
  console.log "bestscore: #{bestscore}"
  response =
    isBestscore:    isBestscore req.body.score, bestscore
    passOneSecond : passOneSecond post_time, moment()
  res.send response
  console.log response
  console.log "score: #{req.body.score}"
  console.log 'ans: ', req.file
  if response.isBestscore
    console.log '[System]The new Best Score!'
    bestscore = req.body.score
  postAnswer HOST, TOKEN, "#{__dirname}/#{req.file.path}"
    
app.get '/bestscore', (req, res) ->
  res.send bestscore : bestscore + ''

app.listen process.argv[2]
