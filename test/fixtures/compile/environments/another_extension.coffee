module.exports = (opts) ->
  class AnotherExtension
    constructor: (@roots) ->
      @roots.config.locals.another_extension ?= {}
      @roots.config.locals.another_extension.test = opts.test
