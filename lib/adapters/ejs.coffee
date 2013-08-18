roots = require '../index'
transformer = require('transformers')['ejs']
_ = require 'underscore'

exports.settings =
  file_type: 'ejs'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    minify: roots.project.cfg 'compress'
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
