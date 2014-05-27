path         = require 'path'
serve_static = require 'serve-static'
charge       = require 'charge'

###*
 * @class Server
 * @classdesc Serves up a roots project locally, handles live reloading
###

class Server

  ###*
   * Creates a new instance of the server
   *
   * @param  {Function} roots - roots class instance
   * @param  {String} dir - directory to serve
  ###

  constructor: (@project) ->

  ###*
   * Start the local server on the given port.
   *
   * @param  {Integer} port - number of port to start the server on
   * @return {Promise} promise for the server object
  ###

  start: (port, cb) ->
    opts = @project.config.server or {}
    opts.log = false

    if @project.config.env == 'development'
      opts.write = content:
        "<!-- roots development configuration -->
        <script>var __livereload = #{@project.config.live_reload};</script>
        <script src='/__roots__/main.js'></script>"
      opts.cache_control = { '**': 'max-age=0, no-cache, no-store' }

    app = charge(@project.config.output_path(), opts)

    if @project.config.env == 'development'
      app.stack.splice app.stack.length-2, 0,
        route: '/__roots__'
        handle: serve_static(path.resolve(__dirname, 'browser'))

    @server = app.start(port, cb)

  ###*
   * Close the server and remove it.
  ###

  stop: (cb) ->
    @server.close(cb)
    delete @server

  ###*
   * Send a message through websockets to the browser.
   *
   * @param  {String} k - message key
   * @param  {*} v - message value
  ###

  send_msg: (k, v) ->
    @server.send(type: k, data: v)

  ###*
   * These three methods send 'reload', 'compiling', and 'error' messages
   * through to the browser.
  ###

  reload: -> @send_msg('reload')
  compiling: -> @send_msg('compiling')
  show_error: (err) -> @send_msg('error', err)

module.exports = Server
