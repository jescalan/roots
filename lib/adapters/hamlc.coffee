roots = require '../index'
transformer = require('transformers')['haml-coffee']
_ = require 'underscore'

exports.settings =
  file_type: 'hamlc'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    uglify: roots.project.conf('compress')
  )

  transformer.render(file.contents, options, cb)
  return
