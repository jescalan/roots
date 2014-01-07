fs     = require 'fs'
path   = require 'path'
_      = require 'lodash'
W      = require 'when'
nodefn = require 'when/node/function'
pipeline = require 'when/pipeline'

class Compiler

  constructor: (@roots) ->

  compile_dynamic: (f) ->
    console.log "compiling dynamic #{f}"

  compile: (f) ->
    adapters = get_adapters.call(@, f)

    nodefn.call(fs.readFile.bind(fs), f, { encoding: 'utf8' }).then (contents) =>

      task = (pair) ->
        index   = pair[0]
        content = pair[1]
        adapter = adapters[index]
        options = configure_options.call(@, { adapter: adapter.name, file: f })

        if not adapter.name then return [++index, content]

        adapter.render(content, options)
          .tap(=> @roots.emit('compile', f))
          .then((out) => return [++index, out])

      pipeline(adapters.map((a,i) => task.bind(@)).reverse(), [0, contents])
        .then((res) => write_file.call(@, f, res[1], adapters[res[0]-1]))

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
  
  # TODO: Locals should be merged from the following contexts
  # - [x] global (conserved until process exits)
  # - [x] adapter-specific (used only with a specific adapter)
  # - [ ] compile-specific (conserved until full compile finished)
  # - [ ] file-specific (conserved until file compile finished)
  
  configure_options = (opts) ->
    res = _.extend(@roots.config.locals || {}, @roots.config[opts.adapter] || {})
    res.filename = opts.file
    res

  get_adapters = (f) ->
    extensions = path.basename(f).split('.').slice(1)
    adapters = []
      
    for ext in extensions.reverse()
      found = false
      for n, c of @roots.config.compilers
        if _.contains(c.extensions, ext)
          adapters.push(c)
          found = true
          break
      if not found then adapters.push(output: ext)

    return adapters

  write_file = (f, content, adapter) ->
    output = @roots.config.out(f, adapter.output)
    nodefn.call(fs.writeFile, output, content)

module.exports = Compiler

###

What's Going On Here?
---------------------

The compiler class is responsible for (you guessed it) compiling files into their destination. It also will copy static files.

The compile method banks heavily on [accord](https://github.com/jenius/accord), a unified interface for compiling across many languages, built specifically for roots. The `get_adapters` method looks at the file's extension(s) and matches them to one or more compilers, depending on the number of file extensions it has. We then read the file's contents and get started with the compile pipeline.

This part is a little more confusing. You can see that upfront a function is defined called "task" - this function runs once for each compile pass on the file. This function recieves an array (pair) that contains the index - aka number of compile pass we're on - and the contents. First, we use the index to grab the correct adapter from the adapters array, then pass the adapter and file names to the `configure_options` method, which creates an options object from user-defined global and compiler-specific settings.

Finally, with the correct adapter, contents, and options in hand, we're ready to get started with the compilation. But before this, we need to ensure that a compile is actually necessary. If there is an extension that hasn't been matched to a compiler, it simply passes through with the same content. If not, we compile the file, emit a `compile` event, and return the newly compiled content.

Now on to how these tasks are actually run. The pipeline function from when.js (https://github.com/cujojs/when/blob/master/docs/api.md#whenpipeline) is used to handle this, acting on an array of as many "task" function as extensions on the file. It kicks off the first compile pass with index zero and the contents read from the file, and any subsequent functions are called with the results of the previous function, as this is how when/pipeline works. When all compiles are finished, the resulting file is written.

The copy method uses streams to asynchronously copy a file as quickly as possible. The method appears a bit unweidly because of it's integration with promises, but it gets the job done, and fast.

###
