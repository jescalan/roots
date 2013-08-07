var connect = require('connect'),
    colors = require('colors'),
    WebSocket = require('faye-websocket'),
    path = require('path'),
    http = require('http'),
    open = require('open'),
    roots = require('./index'),
    sockets = [];

exports.start = function(directory){

  var port = process.env.PORT || 1111;
  var serve_dir = global.options ? path.join(directory, options.output_folder) : directory;

  var app = connect().use(connect.static(serve_dir));
  if (global.options && global.options.debug.status) { app.use(connect.logger('dev')); }
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
  if (global.options.no_livereload) return;
  sockets.forEach(function(socket){
    socket.send('compiling');
    socket.onopen = null;
  });
};

exports.reload = function(){
  if (global.options.no_livereload) return;
  sockets.forEach(function(socket){
    socket.send('reload');
    socket.onopen = null;
  });
  sockets = [];
};
