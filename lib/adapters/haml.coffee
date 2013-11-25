fs    = require 'fs'
roots = require '../index'
haml  = require 'haml'

exports.settings =
  file_type: 'haml'
  target: 'html'

exports.compile = (file, options={}, cb) ->
  source   = fs.readFileSync(file.path, "utf8")
  error    = null
  compiled = ""

  try
    compiled = haml.render(source)
  catch e
    error = e

  cb(error, compiled)
  return
