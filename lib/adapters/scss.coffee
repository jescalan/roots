roots = require '../index'
sass  = require 'node-sass'

exports.settings =
  file_type: 'scss'
  target: 'css'

exports.compile = (file, options={}, cb) ->
  sass.render
    file: file.path
    success: (css) -> cb(null, css)
    error: cb
