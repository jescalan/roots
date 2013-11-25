fs          = require 'fs'
roots       = require '../index'
dogescript  = require 'dogescript'

exports.settings =
  file_type: 'djs'
  target: 'js'

exports.compile = (file, options={}, cb) ->
  compiled = ""
  error = null

  try
    compiled = dogescript(fs.readFileSync(file.path, "utf8"), true)
  catch e
    error = e

  cb error, compiled
  return