module.exports = (opts) ->
  class TestExtension
    constructor: (@roots) ->
      @roots.config.locals.test_extension ?= {}
      @roots.config.locals.test_extension.test = opts.test
