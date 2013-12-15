{EventEmitter} = require('events')
W = require 'when'
nodefn = require 'when/node/function'
guard = require 'when/guard'
keys = require 'when/keys'
mkdirp = require 'mkdirp'
chokidar = require 'chokidar'
minimatch = require 'minimatch'

Config = require './config'
FSParser = require './fs_parser'
Compiler = require './compiler'

class Roots extends EventEmitter

  constructor: (@root) ->
    @config = new Config(@)
    @fs_parser = new FSParser(@)

  compile: (opts) ->
    @emit('start')
    before_hook.call(@)
      .then(@fs_parser.parse.bind(@fs_parser))
      .then(create_folders.bind(@))
      .then(process_files.bind(@))
      # .then(precompile_templates.bind(@))
      .then(after_hook.bind(@))
      .done (=> @emit('done')), ((err) => @emit('error', err))

    return @

  watch: ->
    @compile().once('done', watch_fn.bind(@))
    return @

  # @api private

  before_hook = (ast) ->
    if not @config.before then return W.resolve(ast)
    nodefn.call(@config.before.bind(@))

  after_hook = (ast) ->
    if not @config.after then return
    nodefn.call(@config.after.bind(@))

  create_folders = (ast) ->
    mkdirp.sync(@config.output_path())
    W.map(ast.dirs, guard(guard.n(1), nodefn.lift(mkdirp)))
      .catch((err) -> console.error(err))
      .yield(ast)

  process_files = (ast) ->
    compiler = new Compiler(@)

    keys.all
      compile:
        W.map(ast.dynamic, compiler.compile_dynamic.bind(compiler))
        .then(-> W.map(ast.compiled, compiler.compile.bind(compiler)))
      copy:
        W.map(ast.static, compiler.copy.bind(compiler))

  watch_fn = ->
    chokidar.watch(@root, { ignoreInitial: true, ignored: ignore_fn.bind(@) })
      .on('error', (err) => @emit('error', err))
      .on('change', @compile.bind(@))

  ignore_fn = (p) ->
    f = p.replace(@root, '').slice(1)
    @config.ignores.map((i) -> minimatch(f, i, { dot: true })).filter((i)->i).length

module.exports = Roots

###

What's Going On Here?
---------------------

Welcome to the main entry point to roots! Through this very file, all the magic happens.Roots' code is somewhat of a work of art for me, something I strive to make as beautiful as functional, and consequently something I am hardly ever totally happy with because as soon as I learn or improve, I start seeing more details that could be smoothed out.

Anyway, let's pick this apart. This file represents roots' API, which really is quite simple - it's mostly comprised of a single `compile` function that does all the work. It is organized as a class for code clarity, but as you can see by quickly browsing through, this particular file does not bank heavily on object orientation, as I don't see a lot of benefits to exposing a raw class as the API. What it exposes instead is an event emitter that fires a few events you can listen for.

There is a pretty compressed chunk of promise logic in the `process_files` method which also merits explaining. What' happening here is that two compile processes are being fired off asynchronously. In the first, the dynamic files are compiled followed by the compiled files. In the second, any static assets are copied over. Both of these fire at once, and once they have both finished, the whole promise returns.

###
