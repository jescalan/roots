fs = require 'fs'
path = require 'path'
_ = require 'lodash'
W = require 'when'
nodefn = require 'when/node/function'

class Compiler

  constructor: (@roots) ->

  compile_dynamic: (f) ->
    console.log "compiling dynamic #{f}"

  compile: (f) ->
    adapter = get_adapter.call(@, f)

    adapter.renderFile(f, @roots.config[adapter.name])
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
    nodefn.call(fs.writeFile, output, content)

module.exports = Compiler

###

What's Going On Here?
---------------------

The compiler class is responsible for (you guessed it) compiling files into their destination. It also will copy static files.

The compile method banks heavily on [accord](https://github.com/jenius/accord), a unified interface for compiling across many languages, built specifically for roots. The `get_adapter` method looks at the file's extension and uses this to match it to a compiler. The adapter then renders the file with any custom options passed in through `app.coffee`. It emits a `compile` event with the filename before writing the file to its destination.

The copy method uses streams to asynchronously copy a file as quickly as possible. The method appears a bit unweidly because of it's integration with promises, but it gets the job done, and fast.

###
