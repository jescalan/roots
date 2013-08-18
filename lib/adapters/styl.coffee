roots = require '../index'
transformer = require('transformers')['stylus']
_ = require 'underscore'
axis = require 'axis-css'

exports.settings =
  file_type: 'styl'
  target: 'css'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    minify: roots.project.cfg 'compress'
    inline: roots.project.cfg 'compress'
    filename: file.path
    use: [axis]
  )

  transformer.render(file.contents, options, cb)
  return
