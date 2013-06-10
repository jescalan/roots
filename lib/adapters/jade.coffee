transformer = require('transformers')['jade']

exports.settings =
  file_type: 'jade'
  target: 'html'

exports.compile = (file, cb) ->
  options = {}
  transformer.renderFile(file.path, options, cb)
