var connect = require('connect'),
    colors = require('colors'),
    WebSocket = require('faye-websocket'),
    path = require('path'),
    http = require('http'),
    open = require('open'),
    ws;

exports.start = function(directory){

  var port = process.env.PORT || 1111;
  var public_dir = path.join(directory, 'public');

  var app = connect().use(connect.static(public_dir));
  if (global.options.debug.status) {
    app.use(connect.logger('dev'));
  }
  console.log(('server started on port ' + port).green);

  var server = http.createServer(app).listen(port);
  open('http://localhost:' + port);

  server.addListener('upgrade', function(request, socket, head) {
    ws = new WebSocket(request, socket, head);
    ws.onopen = function(){
      ws.send('connected');
  };
  });

};

exports.reload = function(){
  ws && ws.send('reload');
};