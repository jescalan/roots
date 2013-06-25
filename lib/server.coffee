connect = require 'connect'
colors = require 'colors'
WebSocket = require 'faye-websocket'
path = require 'path'
http = require 'http'
open = require 'open'
sockets = []

exports.start = (directory) ->
  port = process.env.PORT or 1111
  serve_dir = (if global.options then path.join(directory, options.output_folder) else directory)
  app = connect().use(connect.static(serve_dir))
  app.use connect.logger('dev')  if global.options and global.options.debug.status
  console.log ("server started on port #{port}").green
  server = http.createServer(app).listen(port)
  open 'http://localhost:' + port
  server.addListener 'upgrade', (request, socket, head) ->
    ws = new WebSocket(request, socket, head)
    ws.onopen = ->
      ws.send 'connected'

    sockets.push ws

exports.compiling = ->
  if global.options.no_livereload
    sockets.forEach (socket) ->
      socket.send 'compiling'
      socket.onopen = null

exports.reload = ->
  if global.options.no_livereload
    return sockets.forEach((socket) ->
      socket.send 'reload'
      socket.onopen = null
    )
  sockets = []
