roots = require '../index'
transformer = require('transformers')['jade']
_ = require 'underscore'
roots = require '../index'

exports.settings =
  file_type: 'jade'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    pretty: !roots.project.conf('compress')
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
