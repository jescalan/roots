transformer = require('transformers')['stylus']
_ = require 'underscore'
axis = require 'axis-css'

exports.settings =
  file_type: 'styl'
  target: 'css'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    minify: global.options.compress
    filename: file.path
    use: [axis]
  )

  transformer.render(file.contents, options, cb)
  return
