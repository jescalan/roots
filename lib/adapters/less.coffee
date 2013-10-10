roots = require '../index'
transformer = require('transformers')['less']
_ = require 'underscore'

exports.settings =
  file_type: 'less'
  target: 'css'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
