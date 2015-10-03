var request = require('request');
url = 'http://localhost:9000';

request(url, function (error, response, body) {
  if (!error && response.statusCode == 200) {
    console.log(JSON.parse(body).name);
  } else {
    console.log('error: '+ response.statusCode);
  }
});
