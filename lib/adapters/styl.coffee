transformer = require('transformers')['stylus']

exports.compile = (file, cb) ->
  options =
    minify: true

  transformer.renderFile(file.path, options, cb)
