fs = require 'fs'
path = require 'path'
_ = require 'lodash'

class Compiler

  constructor: (@root) ->

  compile_dynamic: (f) ->
    console.log "compiling dynamic #{f}"

  compile: (f) ->
    # get_compiler(f).renderFile(f)
    #   .done()
    get_compiler(f).compile(f)

  copy: (f) ->
    output = f.replace(@root, config.path('output'))
    fs.createReadStream(f).pipe(fs.createWriteStream(output))

  # @api private

  get_compiler = (f) ->
    res = false
    for name, c of config.get().compilers
      if _.contains(c.settings.extensions, path.extname(f).slice(1))
        res = c
    res

module.exports = Compiler
