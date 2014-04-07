fn = require 'when/function'

test = ->
  class Test
    constructor: (@roots) ->

    setup: ->
      fn.call(setTimeout, @roots.emit.bind(@roots, 'test', 'value'), 500)

module.exports =
  extensions: [test()]
