fs = require 'fs'
path = require 'path'
_ = require 'lodash'

class Compiler

  constructor: (@root) ->

  compile_dynamic: (f) ->
    console.log "compiling dynamic #{f}"

  compile: (f) ->
    adapter = get_adapter(f)

    adapter.renderFile(f)
      .then((out) => write_file.call(@, f, out, adapter))

  copy: (f) ->
    output = f.replace(@root, config.path('output'))
    # TODO: need to ensure this has finished
    fs.createReadStream(f).pipe(fs.createWriteStream(output))

  # @api private

  get_adapter = (f) ->
    res = false
    for name, c of config.get().compilers
      if _.contains(c.extensions, path.extname(f).slice(1))
        res = c
    res

  write_file = (filename, content, adapter) ->
    tmp = filename.replace(@root, config.path('output'))
    output = tmp.replace(/\..*$/, ".#{adapter.output}")
    fs.writeFileSync(output, content)

module.exports = Compiler
