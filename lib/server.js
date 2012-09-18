// config
var port = 3000;

var connect = require('connect');
var colors = require('colors');
var open = require('open');
// might want to add supervisor for view reloads

var app = connect()
  .use(connect.logger('dev'))
  .use(connect.static('pipe in the public directory here'));

console.log(('\nserver started on port ' + port + '\n').green);
app.listen(port);
open('http://localhost:' + port);