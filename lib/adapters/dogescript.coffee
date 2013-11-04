fs          = require 'fs'
roots       = require '../index'
dogescript  = require 'dogescript'

exports.settings =
  file_type: 'djs'
  target: 'js'

exports.compile = (file, options={}, cb) ->
  try
    compiled = dogescript(fs.readFileSync(file.path), true)
    cb null, compiled
  catch error
    cb error, null
