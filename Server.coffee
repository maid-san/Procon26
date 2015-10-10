fs = require 'fs'
colors = require 'colors'
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

REG_EXP = /(^.+)|(\d+)/g

#演習用
HOST  = 'testform26.procon-online.net'
TOKEN = '0123456789abcdef'

###本番用
HOST  = '172.16.1.2'
TOKEN = '1f261bf2056249d7'
###

program
  .version require('./package.json').version
  .option  '-p, --port <n>', 'designate number of port releasing', 40000
  .parse   process.argv

bestanswer =
  score: 1024
  stone: 256
timeLastPosted = moment()

isBestscore = (score, bestscore) ->
  score < bestscore

isLowerStone = (stone, beststone) ->
  stone < beststone

latency = (before, after) ->
  if after - before > 1000 then 0 else 10000 - after + before

app.post '/answer', upload.single('answer'), (req, res) ->
  timeRequested = moment()
  response =
    isBestscore : isBestscore  req.body.score, bestanswer.score
    isLowerStone: isLowerStone req.body.stone, bestanswer.stone
    latency: latency timeLastPosted, timeRequested
  res.send response
  console.log "token: #{req.body.token}".green
  console.log "[System]score: #{req.body.score}"
  console.log "[System]stone: #{req.body.stone}"
  console.log "[System]latency: #{response.latency}"
  console.log "[System]timeLastPosted: #{timeLastPosted._d}"
  console.log "[System]timeRequested : #{timeRequested._d}\n"

  if response.isBestscore ||
     response.isLowerStone && req.body.score == bestanswer.score
    timeLastPosted = timeRequested
    console.log '[System]Meu Answer!\n'.red.bold
    sleep.sleep response.latency, ->
      option =
        uri: "http://#{HOST}/answer"
        formData:
          token : TOKEN
          answer: fs.createReadStream("#{__dirname}/#{req.file.path}")
      request.post option, (err, res, body) ->
        console.log body
        match  = body.match(REG_EXP)
        status = match[0]
        score  = Number(match[1])
        stone  = Number(match[2])
        if status == 'success'
          bestanswer.score = score
          bestanswer.stone = stone
          if score != Number(req.body.score)
            console.error '[Warning] Request score is wrong...'
          if stone != Number(req.body.stone)
            console.error '[Warning] Request stone is wrong...'
        console.log "bestanswer: score: #{bestanswer.score},".yellow.bold,
                                "stone: #{bestanswer.stone}" .yellow.bold, '\n'

app.get '/bestanswer', (req, res) ->
  console.log "bestanswer: score: #{bestanswer.score},".yellow.bold,
                          "stone: #{bestanswer.stone}" .yellow.bold
  res.send score: bestanswer.score, stone: bestanswer.stone

app.get '/quest', (req, res) ->
  uri = "http://#{HOST}/quest#{req.query.num}.txt?token=#{TOKEN}"
  request uri, (error, response, body) ->
    if !error && response.statusCode == 200
      console.log body
      res.send body
    else
      console.log 'error : ' + response.statusCode

app.listen program.port, ->
  console.log "Running *:#{program.port}"
