fs     = require 'graceful-fs'
path   = require 'path'
_      = require 'lodash'
W      = require 'when'
nodefn = require 'when/node/function'
pipeline = require 'when/pipeline'
sequence = require 'when/sequence'

class Compiler

  constructor: (@roots) ->
    @options = {}

  compile: (@category, f) ->
    (new CompileFile(@roots, @category, f, @options)).run()

module.exports = Compiler

# @api private

class CompileFile

  constructor: (@roots, @category, @path, @options) ->
    @adapters = get_adapters.call(@)
    @local_options = { filename: @path }

  run: ->
    read_file(@path)
      .then((o) => @content = o)
      .then(=> sequence(@roots.extensions.hooks('compile_hooks.before_file'), @))
      .then(each_pass.bind(@))
      .tap((out) => @content = out)
      .tap(=> @roots.emit('compile', @path))
      .then(=> sequence(@roots.extensions.hooks('compile_hooks.after_file'), @))
      .then(write_file.bind(@))
  
  # @api private

  read_file = (f) ->
    nodefn.call(fs.readFile, f, { encoding: 'utf8' })

  write_file = (after_results) ->
    if _.any(after_results, ((r) -> not r)) then return
    output = @roots.config.out(@path, _.last(@adapters).output)
    nodefn.call(fs.writeFile, output, @content)

  get_adapters = ->
    extensions = path.basename(@path).split('.').slice(1)
    adapters = []
    
    for ext in extensions.reverse()
      compiler = _.find(@roots.config.compilers, (c) -> _.contains(c.extensions, ext))
      adapters.push(if compiler then compiler else { output: ext })

    return adapters

  each_pass = ->
    pass = new CompilePass(@)
    pipeline(@adapters.map((a,i) => pass.run.bind(pass,a,i+1)), @content)

class CompilePass

  constructor: (@file) ->

  run: (@adapter, @index, @content) ->
    @opts = configure_options.call(@)

    sequence(@file.roots.extensions.hooks('compile_hooks.before_pass'), @)
      .then(compile_or_pass.bind(@))
      .then((out) => @content = out)
      .then(=> sequence(@file.roots.extensions.hooks('compile_hooks.after_pass'), @))
      .then(=> @content)

  # @api private
  
  configure_options = ->
    _.extend @file.roots.config.locals || {},         # global
             @file.roots.config[@adapter.name] || {}, # per adapter
             @file.local_options,                     # per file
             { site: @file.options }                  # per compile pass
  
  compile_or_pass = ->
    if not @adapter.name then return @content
    @adapter.render(@content, @opts)

###

What's Going On Here?
---------------------

This is potentially the most complex piece of the roots core, which is good
and bad. It's good because it is definitely digestible, thanks to the use of
promises and the fantastic utilities provided by when.js. It's bad because if
you found yourself here trying to make a quick patch, it's going to take you a
while to grok all the logic going on in here.

The compiler contains three different classes. The first one is only
initialized once, when the base roots class is initialized. This class pulls
out any hooks that are being used by roots extensions, which is something we
don't want to do for every file. It's main method, `run` is called once for
each file being compiled. Since we need an isolated scope for each compilation
as this is an async operation and multiple files could potentially be
compiling at the same time, this task initializes a new private CompileFile
class to contain that scope.

The CompileFile instance is responsible for all operations concerned with
compiling the entire file. Keep in mind that the compilation process can
involve multiple compile passes, since multipass compilation is core to roots
-- all per-compile-pass logic is delegated to a separate class with its own
scope, which will be described in the next paragraph. So in order to prepare
the file for compilation, its contents need to be read, and its extension(s)
need to be scanned to detemine which compile adapter(s) will be used to
process the file. Once those two are set, there is an opportunity for
extensions to come in and do whatever they need to do. After this, the file is
fully compiled. For this, each adapter is paired with an instance of the
CompilePass class which takes care of the compile logic. Once finished here,
the compile event is emitted, extensions have the chance to jump in with an
after hook, and finally the file is written with the newly compiled contents.

The actual compilation process is executed in a scope of its own to keep
things clean and separate, and since multiple ones can be going on at once.
This task allows extensions to get in a before hook with access to the number
of compile pass and the adapter it's on. Then the actual compile runs using an
adapter from accord. Finally, an after hook gives the same access as before,
but also with the compiled content available. Finally, the compiled content is
passed through to be used by the next compile pass, or if it's the last one,
control returns to the CompileFile instance.

###
