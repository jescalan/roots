roots = require '../index'
_ = require 'underscore'

#snockets is temporary, this will be replaced with transformers
Snockets = require 'snockets'
snockets = new Snockets()

exports.settings =
  file_type: 'coffee'
  target: 'js'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    header: false
    bare: global.options.coffeescript_bare
    minify: roots.project.conf 'compress'
    filename: file.path
    async: false # for snockets
  )

  # custom compiler for bare coffeescript
  if options.bare
    Snockets.compilers.coffee.compileSync = (sourcePath, source) ->
      return require('coffee-script').compile(source, { filename: sourcePath, bare: true })

  try
    compiled = snockets.getConcatenation file.path, options
  catch err
    error = err
    
  cb(error, compiled)

  return
