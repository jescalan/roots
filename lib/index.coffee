require('./analytics')

{EventEmitter} = require('events')
fs             = require 'fs'
path           = require 'path'
Config         = require './config'
Extensions     = require './extensions'

###*
 * @class
 * @classdesc main roots class, public api for roots
###

class Roots extends EventEmitter

  ###*
   * Given a path to a project, set up the config and return a roots instance
   * @param  {[type]} root - path to a folder
   * @return {Function} - instance of the Roots class
  ###

  constructor: (@root, @opts={}) ->
    @root = path.resolve(@root)
    if not fs.existsSync(@root) then throw new Error("path does not exist")
    @extensions = new Extensions(@)
    @config = new Config(@, @opts)

  ###*
   * Alternate constructor, creates a new roots project in a given folder and
   * returns a roots instance for this project. Takes an object with these keys:
   *
   * path: path to the folder you'd like to create and initialize a project in
   * template: name of the template you'd like to use (default: base)
   * overrides: data to pass to the template, skips prompts
   * defaults: sets default values for the template's prompts
   *
   * @param  {Object} opts - options object, described above
   * @return {Promise} Promise for a Roots class instance
  ###

  @new: (opts) ->
    New = require('./api/new')
    (new New(@)).exec(opts)

  ###*
   * Exposes an API to manage your roots project templates through sprout.
   * See api/template for details. The defineGetter hack makes it such that
   * while you can call roots.template.x like an object, the dependencies
   * needed for it are lazy-loaded only when you actually make the call.
   * This boosts the require time of this file by ~400ms.
  ###

  @__defineGetter__('template', -> require('./api/template'))

  ###*
   * Compiles a roots project. Wow.
   *
   * @return {Promise} promise for finished compile
  ###

  compile: (opts) ->
    Compile = require('./api/compile')
    (new Compile(@)).exec(opts)

  ###*
   * Watches a folder for changes and compiles whenever changes happen.
   *
   * @return {Object} [chokidar](https://github.com/paulmillr/chokidar) instance
  ###

  watch: ->
    Watch = require('./api/watch')
    (new Watch(@)).exec()

  ###*
   * Removes a project's output folder.
   * @return {Promise} promise for removed output folder
  ###

  clean: ->
    Clean = require('./api/clean')
    (new Clean(@)).exec()

  deploy: (opts) ->
    Deploy = require('./api/deploy')
    (new Deploy(@)).exec(opts)

  ###*
   * If an irrecoverable error has occurred, exit the application with
   * as clear an error as possible and a specific exit code.
   *
   * @param {Integer} code - numeric error code
   * @param {String} details - any additional details to be printed
  ###

  bail: require('./api/bail')


Roots.analytics = (args) ->
  analytics = require('./api/analytics')
  analytics(args)

module.exports = Roots
