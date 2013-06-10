transformer = require('transformers')['coffee-script']

exports.settings =
  file_type: "coffee"
  target: "js"

exports.compile = (file, cb) ->
  options =
    header: false
    bare: global.options.coffeescript_bare
    minify: global.options.compress

  transformer.renderFile(file.path, options, cb)
