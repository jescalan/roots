roots = require '../index'
transformer = require('transformers')['hogan']
_ = require 'underscore'

exports.settings =
  file_type: 'mustache'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
