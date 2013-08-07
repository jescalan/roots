_ = require 'underscore'
Adapter = require './adapter'

#snockets is temporary, this will be replaced with transformers
Snockets = require 'snockets'
snockets = new Snockets()

class CoffeeScript extends Adapter
  ###*
   * An array of formats that this Adapter can take.
   * @type {Array}
  ###
  inputFormats: ['coffee']

  ###*
   * The format that the Adapter spits out
   * @type {String}
  ###
  outputFormat: 'js'

  ###*
   * The function that will be called to compile the Asset. 
   * @param {[type]} file [description]
   * @param {[type]} options={} [description]
   * @param {Function} cb [description]
   * @return {[type]} [description]
  ###
  compile: (file, options={}, cb) ->
    _.defaults(options,
      header: false
      bare: global.options.coffeescript_bare
      minify: global.options.compress
      filename: file.path
      async: false # for snockets
    )

    # custom compiler for bare coffeescript
    if options.bare
      Snockets.compilers.coffee.compileSync = (sourcePath, source) ->
        return require('coffee-script').compile(source, { filename: sourcePath, bare: true })

    try
      compiled = snockets.getConcatenation file.path, options
    catch err
      error = err
      
    cb(error, compiled)
    return

module.exports = CoffeeScript
