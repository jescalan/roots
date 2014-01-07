W      = require 'when'
nodefn = require 'when/node/function'
guard  = require 'when/guard'
keys   = require 'when/keys'
mkdirp = require 'mkdirp'

FSParser = require '../fs_parser'
Compiler = require '../compiler'

class Compile

  constructor: (@roots) ->
    @fs_parser = new FSParser(@roots)
    @compiler = new Compiler(@roots)

  exec: ->
    @roots.emit('start')

    before_hook.call(@)
      .then(@fs_parser.parse.bind(@fs_parser))
      .then(create_folders.bind(@))
      .then(process_files.bind(@))
      .then(after_hook.bind(@))
      .done (=> @roots.emit('done')), ((err) => @roots.emit('error', err))

  # @api private

  _hook_method = (hook) ->
    if not hook then return W.resolve()

    if Array.isArray(hook)
      hooks = hook.map((h) => nodefn.call(h.bind(@roots)))
    else if typeof hook == 'function'
      hooks = [nodefn.call(hook.bind(@roots))]
    else
      return W.reject('before hook should be a function or array')

    W.all(hooks)

  before_hook = ->
    _hook_method.call(@, @roots.config.before)

  after_hook = (ast) ->
    _hook_method.call(@, @roots.config.after)

  create_folders = (ast) ->
    mkdirp.sync(@roots.config.output_path())
    W.map(ast.dirs, guard(guard.n(1), nodefn.lift(mkdirp)))
      .catch((err) -> console.error(err))
      .yield(ast)

  process_files = (ast) ->
    keys.all
      compile:
        W.map(ast.dynamic, @compiler.compile_dynamic.bind(@compiler))
        .then(=> W.map(ast.compiled, @compiler.compile.bind(@compiler)))
      copy:
        W.map(ast.static, @compiler.copy.bind(@compiler))

module.exports = Compile

###

What's Going On Here?
---------------------

This really is the core of roots - the compile function. Heavily promise-based in here to keep things organized, this method parses the project structure, figured out which files need to be compiled and how, and exposes an event emitter that can be used to listen to what it's doing along the way.

There is a pretty compressed chunk of promise logic in the `process_files` method which also merits explaining. What' happening here is that two compile processes are being fired off asynchronously. In the first, the dynamic files are compiled followed by the compiled files. In the second, any static assets are copied over. Both of these fire at once, and once they have both finished, the whole promise returns.

###
