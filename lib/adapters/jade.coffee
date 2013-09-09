transformer = require('transformers')['jade']
_ = require 'underscore'
roots = require '../index'

exports.settings =
  file_type: 'jade'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    pretty: (if roots.project.mode == 'build' then false else true)
    filename: file.path
  )

  transformer.render(file.contents, options, cb)
  return
