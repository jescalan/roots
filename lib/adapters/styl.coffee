transformer = require('transformers')['stylus']
_ = require 'underscore'
axis = require 'axis-css'
Adapter = require './adapter'

class Stylus extends Adapter
  ###*
   * An array of formats that this Adapter can take.
   * @type {Array}
  ###
  inputFormats: ['styl', 'stylus']

  ###*
   * The format that the Adapter spits out
   * @type {String}
  ###
  outputFormat: 'css'

  ###*
   * The function that will be called to compile the Asset.
   * @param {[type]} file [description]
   * @param {[type]} options={} [description]
   * @param {Function} cb [description]
   * @return {[type]} [description]
  ###
  compile: (file, options={}, cb) ->
    _.defaults(options,
      minify: global.options.compress
      inline: global.options.compress
      filename: file.path
      use: [axis]
    )

    transformer.render(file.contents, options, cb)
    return
