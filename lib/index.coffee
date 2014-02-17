require 'colors'
{EventEmitter} = require('events')
fs             = require 'fs'
Config         = require './config'
Extensions     = require './extensions'

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

  constructor: (@root) ->
    if not fs.existsSync(@root) then throw new Error("path does not exist")
    @extensions = new Extensions(@)
    @config = new Config(@)

  ###*
   * Alternate constructor, creates a new roots project in a given folder and
   * returns a roots instance for this project. Takes an object with these keys:
   *
   * path: path to the folder you'd like to create and initialize a project in
   * template: name of the template you'd like to use (default: base)
   * options: additional options to pass to sprout
   * 
   * @param  {Object} opts - options object, described above
   * @return {Function} Roots class instance
  ###
  
  @new: (opts) ->
    n = new (require('./api/new'))(@)
    n.exec(opts).on('done', (root) => if opts.done then opts.done(new @(root)))
    return n

  ###*
   * Exposes an API to manage your roots project templates through sprout.
   * See api/template for details.
  ###

  @template: require('./api/template')

  ###*
   * Compiles a roots project. Wow.
   * @return {Function} instance of itself for chaining
  ###

  compile: ->
    # TODO: does this actually provide a speed boost?
    Compile = require('./api/compile')
    (new Compile(@)).exec()
    return @

  ###*
   * Watches a folder for changes and compiles whenever changes happen.
   * 
   * @return {Function} instance of itself for chaining
  ###

  watch: ->
    (new (require('./api/watch'))(@)).exec()
    return @

  ###*
   * If an irrecoverable error has occurred, exit the application with
   * as clear an error as possible and a specific exit code.
   *
   * @param {Integer} code - numeric error code
   * @param {String} details - any additional details to be printed
  ###

  bail: (code, details) ->
    switch code
      when 125 then msg = "malformed extension error"

    console.error "\nFLAGRANT ERROR!\n".red.bold
    console.error "It looks like there was a " + "#{msg}".bold + "."
    console.error "Check out " + "http://roots.cx/errors##{code}".green + " for more help\n"

    if details
      console.error "DETAILS:".yellow.bold
      console.error details

    process.exit(code)

module.exports = Roots
