roots = require '../index'
transformer = require('transformers')['markdown']
_ = require 'underscore'

exports.settings =
  file_type: 'md'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
