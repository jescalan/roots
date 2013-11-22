roots = require '../index'
_     = require 'underscore'
fs    = require 'fs'

#snockets is temporary, this will be replaced with transformers
Snockets = require 'snockets'
snockets = new Snockets()

exports.settings =
  file_type: 'coffee'
  target: 'js'

error_formatter = (error, file) ->
  return error unless error

  new Error "
  \n\nFile: #{file.relative_path}
  \nLine\n
  #{error.location.first_line}| #{error.message} \n
  \n
  #{fs.readFileSync(file.path, 'utf8').split("\n")[error.location.first_line]}\n
  #{new Array(error.location.first_column).join(' ') + '^'}\n\n"

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    header: false
    bare: roots.project.compiler_options.coffeescript.bare
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

  cb(error_formatter(error, file), compiled)

  return
