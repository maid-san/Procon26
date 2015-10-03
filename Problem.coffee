request = require 'request'

host = 'testform26.procon-online.net'
token = '0123456789abcdef'

###仕様に含まれてないやつ
getProblem = (url) =>
    request.get url, (error, response, body) =>
        console.log if !error && response.statusCode == 200 then \
        body else 'error : ' + response.statusCode

'http://' + host + '/quest1.txt' + '?token=' + token
###

postProblem = (host, token, file) =>
    option =
        uri : 'http://' + host + '/answer'
        form :
            token : token
            answer : file

    request.post option, (error, response, body) =>
        console.log if !error && response.statusCode == 200 then \
        body else 'error : ' + response.statusCode

postProblem host, token, '@Quest1.txt'
