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
      .tap(=> @roots.emit('compile', f))
      .then((out) => write_file.call(@, f, out, adapter))

  copy: (f) ->
    deferred = W.defer()

    output = @roots.config.out(f)
    rs = fs.createReadStream(f)
    ws = fs.createWriteStream(output)
    rs.pipe(ws)

    rs.on('error', deferred.reject)
    ws.on('error', deferred.reject)

    ws.on 'close', =>
      @roots.emit('copy', f)
      deferred.resolve()

    return deferred.promise

  # @api private

  get_adapter = (f) ->
    res = false
    for name, c of @roots.config.compilers
      if _.contains(c.extensions, path.extname(f).slice(1))
        res = c
    res

  write_file = (f, content, adapter) ->
    output = @roots.config.out(f, adapter.output)
    fs.writeFileSync(output, content)

module.exports = Compiler
