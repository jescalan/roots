var connect = require('connect'),
    colors = require('colors'),
    WebSocket = require('faye-websocket'),
    path = require('path'),
    http = require('http'),
    open = require('open'),
    roots = require('./index'),
    sockets = [];

exports.start = function(serve_dir){
  var port = process.env.PORT || 1111;

  var app = connect().use(connect.static(serve_dir));
  if (roots.project.debug) app.use(connect.logger('dev'));
  roots.print.log('server started on port ' + port, 'green');

  var server = http.createServer(app).listen(port);
  open('http://localhost:' + port);

  server.addListener('upgrade', function(request, socket, head) {
    var ws = new WebSocket(request, socket, head);
    ws.onopen = function(){ ws.send('connected'); };
    sockets.push(ws);
  });

};

exports.compiling = function(){
  if (!roots.project.livereloadEnabled) return;
  sockets.forEach(function(socket){
    socket.send('compiling');
    socket.onopen = null;
  });
};

exports.reload = function(){
  if (!roots.project.livereloadEnabled) return;
  sockets.forEach(function(socket){
    socket.send('reload');
    socket.onopen = null;
  });
  sockets = [];
};
