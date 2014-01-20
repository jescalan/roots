_ = require 'lodash'
path = require 'path'

class Compiled

  constructor: (@roots) ->
    @category = 'compiled'

    @fs =
      extract: true
      ordered: true
      detect: (f) =>
        exts = _(@roots.config.compilers).map((i)-> i.extensions).flatten().value()
        _.contains(exts, path.extname(f).slice(1))

module.exports = Compiled
