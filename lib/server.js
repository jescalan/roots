var connect = require('connect'),
    colors = require('colors'),
    io = require('socket.io'),
    path = require('path'),
    http = require('http'),
    open = require('open'),
    debug = require('./debug'),
    socket;

exports.start = function(directory){

  // config
  var port = 3000;
  var public_dir = path.join(directory, 'public');

  // middleware here has to inject the live reload code onto the page

  var app = connect().use(connect.static(public_dir));
  if (debug.status) { app.use(connect.logger('dev')) }
  console.log(('\nserver started on port ' + port).green);

  var server = http.createServer(app).listen(port);
  open('http://localhost:' + port);

  var socketio = io.listen(server, { log: false });

  socketio.sockets.on('connection', function(s){
    socket = s;
    socket.emit('connected', true);
  });

}

exports.reload = function(){ socket.emit('reload', true); }