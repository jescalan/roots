connect = require 'connect'
colors = require 'colors'
WebSocket = require 'faye-websocket'
path = require 'path'
http = require 'http'
open = require 'open'
roots = require './index'

class Server
  ###*
   * Used to start the server
   * @param {[type]} port The port that that server is gonna run on.
   * @param {[type]} openBrowser=true Should we automatically open a browser
     window?
   * @return {[type]} [description]
  ###
  constructor: (port, openBrowser=true) ->
    @port = port

    app = connect().use(connect.static(roots.project.path('public')))
    app.use connect.logger(@logger)

    @server = http.createServer(app).listen(@port)
    @server.addListener 'upgrade', (request, socket, head) ->
      ws = new WebSocket(request, socket, head)
      ws.onopen = ->
        ws.send 'connected'

      @sockets.push ws

    roots.print.log "server started on port #{@port}", 'green'
    if openBrowser then open "http://localhost:#{port}"

    roots.project.on 'compiling', -> @compiling
    roots.project.on 'reload', -> @reload

  sockets: []

  port: 0

  server: undefined

  ###*
   * Function that takes all error messages from the server and sends them to
     the printer, or other areas in roots that are supposed to deal with them
   * @param {[type]} req [description]
   * @param {[type]} res [description]
   * @return {[type]} [description]
  ###
  logger: (req, res) ->
    roots.print.debug res

  compiling: ->
    if not roots.project.livereloadEnabled
      @sockets.forEach (socket) ->
        socket.send 'compiling'
        socket.onopen = null

  reload: ->
    if not roots.project.livereloadEnabled
      return @sockets.forEach((socket) ->
        socket.send 'reload'
        socket.onopen = null
      )
    @sockets = []

module.exports = Server
