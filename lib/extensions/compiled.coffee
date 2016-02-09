_ = require 'lodash'
path = require 'path'

module.exports = ->

  ###*
   * @class
   * @classdesc This extension puts files into a "compiled" category if their
   * extensions match to an extension that an installed compiler is looking for
  ###

  class Compiled
    constructor: (@roots) ->
      @category = 'compiled'

    fs: ->
      extract: true
      ordered: true
      detect: detect_fn.bind(@)

    ###*
     * Detects whether a file should be compiled or not
     *
     * @private
     * @param  {File} f - file object
     * @return {Boolean} whether the file should be compiled or not
    ###

    detect_fn = (f) ->
      exts = _(@roots.config.compilers).map((i)->i.extensions).flatten().value()
      _.includes(exts, path.extname(f.relative).slice(1))
