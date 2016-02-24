path         = require 'path'
serve_static = require 'serve-static'
charge       = require 'charge'
browsersync  = require 'browser-sync'
_            = require 'lodash'

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
    bs_options =
      port: port
      logLevel: 'silent'
      notify: false
      open: @project.config.open_browser
      server:
        baseDir: @project.config.output_path()

    if @project.config.browser then _.merge(bs_options, @project.config.browser)

    # add charge middleware after merge to prevent errors
    opts = @project.config.server or {}
    middlewares = []

    if opts.clean_urls
      middlewares.push(charge.hygienist(
        @project.config.output_path(), opts.clean_urls
      ))
    if opts.exclude
      middlewares.push(charge.escapist(opts.exclude))
    if opts.auth
      middlewares.push(charge.publicist(opts.auth))
    if opts.cache_control
      middlewares.push(charge.archivist(opts.cache_control))
    if opts.gzip
      middlewares.push(charge.minimist(opts.gzip))
    if opts.log
      middlewares.push(charge.columnist(opts.log))
    if opts.error_page
      middlewares.push(charge.apologist(opts.error_page))

    bs_options.server.middleware = middlewares

    @bs.init(bs_options, cb)

  ###*
   * Close the server and remove it.
  ###

  stop: (cb) ->
    @bs.exit()
    cb()

  ###*
   * Reload the browser
  ###

  reload: ->
    @bs.reload()

  ###*
   * Inject loading spinner while compiling
  ###
  compiling: ->
    @bs.notify('compiling...', 999999)

  ###*
   * Sanitize error message and inject into page
   * @param  {Error} err - an error object
  ###

  show_error: (err) ->
    err = err.toString() if err instanceof Error
    cleanError = if err.replace
      err.replace(/(\r\n|\n|\r)/gm, '<br>')
    else
      "compile error!"
    @bs.notify(cleanError, 999999)

module.exports = Server
