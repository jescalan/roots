path         = require 'path'
serve_static = require 'serve-static'
charge       = require 'charge'
browsersync  = require 'browser-sync'

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
    @bs = browsersync.create()

  ###*
   * Start the local server on the given port.
   *
   * @param  {Integer} port - number of port to start the server on
   * @return {Promise} promise for the server object
  ###

  start: (port, cb) ->
    opts = @project.config.server ? {}
    opts.log = false

    # use port, use options
    @bs.init({
      port: port
      server:
        baseDir: @project.config.output_path()
        logLevel: 'silent'
    }, cb)

  ###*
   * Close the server and remove it.
  ###

  stop: (cb) ->
    @bs.exit()

  ###*
   * Reload the browser
  ###

  reload: ->
    @bs.reload()

  ###*
   * Inject loading spinner while compiling
  ###
  compiling: ->
    @bs.notify('<div id="roots-load-container"><div id="roots-compile-loader">
    <div id="l1"></div><div id="l2"></div><div id="l3"></div><div id="l4"></div>
    <div id="l5"></div><div id="l6"></div><div id="l7"></div><div id="l8"></div>
    </div></div>')

  ###*
   * Sanitize error message and inject into page
   * @param  {Error} err - an error object
  ###

  show_error: (err) ->
    err = err.toString() if err instanceof Error
    cleanError = if err.replace
      err.replace(/(\r\n|\n|\r)/gm, '<br>')
    else
      ""
    @bs.notify("<div id='roots-error'><pre><span>compile
    error</span>#{cleanError}</pre></div>")

module.exports = Server
