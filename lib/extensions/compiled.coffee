_ = require 'lodash'
path = require 'path'

class Compiled

  constructor: (@roots) ->

  fs: ->
    category: 'compiled'
    extract: true
    ordered: true
    detect: detect_fn.bind(@)
  
  # @api private
  
  detect_fn = (f) ->
    exts = _(@roots.config.compilers).map((i)-> i.extensions).flatten().value()
    _.contains(exts, path.extname(f).slice(1))

module.exports = Compiled
