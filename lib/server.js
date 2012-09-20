var connect = require('connect'),
    colors = require('colors'),
    io = require('socket.io'),
    path = require('path'),
    open = require('open');

// might want to add supervisor for view reloads

exports.start = function(directory){

  // config
  var port = 3000;

  console.log(directory);

  var app = connect()
    .use(connect.logger('dev'))
    .use(connect.static(path.join(directory, 'public')));

  console.log(('\nserver started on port ' + port + '\n').green);
  app.listen(port);
  open('http://localhost:' + port);

  // var socket = io.listen(app);

}