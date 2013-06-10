transformer = require('transformers')['ejs']

exports.settings =
  file_type: 'ejs'
  target: 'html'

exports.compile = (file, cb) ->
  options = {}
  transformer.renderFile(file.path, options, cb)
