transformer = require('transformers')['ejs']
_ = require 'underscore'
Adapter = require './adapter'

class EJS extends Adapter
  ###*
   * An array of formats that this Adapter can take.
   * @type {Array}
  ###
  inputFormats: ['ejs']

  ###*
   * The format that the Adapter spits out
   * @type {String}
  ###
  outputFormat: 'html'

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
      filename: file.path
    )

    transformer.render(file.contents, options, cb)
    return

module.exports = EJS
