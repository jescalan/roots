require 'colors'
{EventEmitter} = require('events')
fs             = require 'fs'
Config         = require './config'
Extensions     = require './extensions'
util           = require 'util'

Compile = require('./api/compile')
Watch   = require('./api/watch')

###*
 * @class
 * @classdesc main roots class, public api for roots
###

class Roots extends EventEmitter

  ###*
   * Given a path to a project, set up the configuration and return a roots instance
   * @param  {[type]} root - path to a folder
   * @return {Function} - instance of the Roots class
  ###

  constructor: (@root, opts={}) ->
    if not fs.existsSync(@root) then throw new Error("path does not exist")
    @extensions = new Extensions(@)
    @config = new Config(@, opts)

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
    (require('./api/new'))(@, opts)

  ###*
   * Exposes an API to manage your roots project templates through sprout.
   * See api/template for details.
  ###

  @template: require('./api/template')

  ###*
   * Compiles a roots project. Wow.
   *
   * @return {Promise} promise for finished compile
  ###

  compile: ->
    (new Compile(@)).exec()

  ###*
   * Watches a folder for changes and compiles whenever changes happen.
   *
   * @return {Object} [chokidar](https://github.com/paulmillr/chokidar) instance
  ###

  watch: ->
    (new Watch(@)).exec()

  ###*
   * If an irrecoverable error has occurred, exit the application with
   * as clear an error as possible and a specific exit code.
   *
   * @param {Integer} code - numeric error code
   * @param {String} details - any additional details to be printed
  ###

  bail: (code, message, ext) ->
    switch code
      when 125 then name = "Malformed Extension"
      when 126 then name = "Malformed Write Hook Output"

    console.error "\nFLAGRANT ERROR!\n".red.bold
    console.error "It looks like there was a " + "#{name}".bold + " Error."
    console.error "Check out " + "http://roots.cx/errors##{code}".green + " for more help\n"

    console.error "Reason:".yellow.bold
    console.error message
    console.error "\nOffending Extension:".yellow.bold
    console.error "Name: ".bold + ext.constructor.name
    process.stderr.write "Extension: ".bold
    console.error util.inspect(ext, { colors: true, showHidden: true })
    process.stderr.write "Prototype: ".bold
    console.error ext.constructor.prototype

    class RootsError extends Error
      constructor: (@name, @message, @ext, @code) ->
        Error.call(@)
        Error.captureStackTrace(@, @constructor)

    throw new RootsError(name, message, ext, code)

module.exports = Roots
