fs = require 'fs'
path = require 'path'
_ = require 'lodash'
W = require 'when'

class Compiler

  constructor: (@roots) ->

  compile_dynamic: (f) ->
    console.log "compiling dynamic #{f}"

  compile: (f) ->
    adapter = get_adapter.call(@, f)

    adapter.renderFile(f)
      .then((out) => write_file.call(@, f, out, adapter))

  copy: (f) ->
    deferred = W.defer()

    output = f.replace(@roots.root, @roots.config.path('output'))
    rs = fs.createReadStream(f)
    ws = fs.createWriteStream(output)
    rs.pipe(ws)

    rs.on('error', deferred.reject)
    ws.on('error', deferred.reject)
    ws.on('close', deferred.resolve)

    return deferred.promise

  # @api private

  get_adapter = (f) ->
    res = false
    for name, c of @roots.config.compilers
      if _.contains(c.extensions, path.extname(f).slice(1))
        res = c
    res

  write_file = (filename, content, adapter) ->
    tmp = filename.replace(@roots.root, @roots.config.path('output'))
    output = tmp.replace(/\..*$/, ".#{adapter.output}")
    fs.writeFileSync(output, content)

module.exports = Compiler
