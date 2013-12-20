path      = require 'path'
nodefn    = require 'when/node/function'
http      = require 'http'
connect   = require 'connect'
injector  = require 'injector_js'
util      = require 'util'
WebSocket = require 'faye-websocket'

module.exports = class
  constructor: (@roots, @dir) ->

  sockets: []

  start: (port) ->
    app = connect()

    if @roots.config.env == 'development' then inject_development_js.call(@, app)
    app.use(connect.static(@roots.config.output_path()))

    @server = http.createServer(app)
    if @roots.config.env == 'development' then initialize_websockets.call(@)

    nodefn.call(@server.listen.bind(@server), port).yield(@server)

  close: ->
    @server.close()
    delete @server

  send_msg: (k, v) ->
    sock.send(JSON.stringify(type: k, data: v)) for sock in @sockets

  reload: -> @send_msg('reload')
  compiling: -> @send_msg('compiling')
  show_error: (err) -> @send_msg('error', err)

  # @api private

  inject_development_js = (app) ->
    app.use(injector content:
      "<!-- roots development configuration -->
      <script>var __livereload = #{@roots.config.live_reload};</script>
      <script src='__roots__/main.js'></script>"
    )
    app.use('/__roots__', connect.static(path.resolve(__dirname, 'browser')))

  initialize_websockets = ->
    @server.on 'upgrade', (req, socket, body) =>
      if WebSocket.isWebSocket(req)
        ws = new WebSocket(req, socket, body)
        ws.on('open', => @sockets.push(ws))

###

What is this all about?
--------------------

* Creates a simple static web server that serves up the public compiled dir
* The constructor allows you to pass any root directoy
* Exposes two public API methods
  * start - returns a promise
  * stop - sync
* 'Start' injects some javascript at the bottom of the page for livereload if in development

###
