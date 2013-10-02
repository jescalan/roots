path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
EventEmitter = require('events').EventEmitter
_ = require 'underscore'
Q = require 'q'
async = require 'async'

# roots utils
adapters = require './adapters'
compress = require './utils/compressor'
output_path = require './utils/output_path'
FileHelper = require './utils/file_helper'
roots = require './index'

# roots extensions
DynamicContentExtension = require './extensions/dynamic_content'
LayoutsExtension = require './extensions/layouts'

class Compiler extends EventEmitter

  # decorator pattern
  # http://coffeescriptcookbook.com/chapters/design_patterns/decorator
  constructor: ->
    @extensions = [new DynamicContentExtension, new LayoutsExtension]

  register: (ext) -> @extensions.push(ext)

  ###*
   * Emits an event to notify listeners that everything is compiled
   * @fires Compiler#finished
  ###

  finish: ->
    @emit 'finished'

  ###*
   * Provides extensions with hooks into the compile process
   * @param  {String} name - name of the hook
   * @param {Object} ctx - compile context
   * @description
   * Goes through each extension, calls the function with `ctx` as its
   * context, each hook returns a possibly modified instance of the context,
   * and that is passed to the next function as it's context. this way, each
   * function not only has access to the local context, but also has the
   * opportunity to modify it going forward.
   * 
   * Finally, the context is passed out through the deferred handler and
   * flows through to the rest of the compile process.
  ###

  hook: (name, ctx) ->
    deferred = Q.defer()

    # console.log ctx.adapter if name == 'compile'
    
    fn = (m,ext,cb) =>
      @hook_single(ext, name, ctx)
        .catch((err) -> cb(err, null))
        .then((nm) -> cb(null, nm))

    async.inject @extensions, ctx, fn, (err, res) ->
      if err then return deferred.reject(err)
      deferred.resolve(res)

    return deferred.promise

  hook_single: (ext, name, ctx) ->
    deferred = Q.defer()

    hook = ext["#{name}_hook"]

    try
      if hook then hook.call(ctx, deferred) else deferred.resolve(ctx)
    catch err
      deferred.reject(err)

    return deferred.promise

  ###*
   * Compiles a given file. Figures out how to compile based on extension, and
   * can handle multipass compiles if a file has multiple extensions.
   * @param {string} file - path to a file
   * @param {function} cb - executed when finished
  ###

  compile: (file, cb) ->

    # local context is consistent even though compile is being called
    # on multiple files, as rapidly as possible.
    # 
    # - `fh` is the file helper, an object that contains a good amount of
    # useful information about a file, like it's full path, contents, etc.
    # - `index` is used to track what number of compile passes have been
    # taken on a file, since roots can compile a single file multiple times.
    
    ctx =
      fh: new FileHelper(file)
      index: 0

    # the 'hook' method allows extensions to be incorporated into the
    # roots compile process. for maximum flexibility, extensions can
    # edit the context in any way, multiple extensions can be called
    # on the same hook, and any extension can run sync or async.
    # see `hook` above for further explanation

    @hook('before', ctx)
      .then(@compile_each.bind(@))
      .catch((err) => @emit('error', err))
      .done(cb)

  compile_each: (ctx) ->
    deferred = Q.defer()

    # before the file is compiled, roots determines which compile
    # adapters are needed to compile it correctly. it does this by
    # reading through the file extensions. since roots can compile a
    # single file multiple times, adapters is an array.
    ctx.adapters = get_adapters_by_extension(path.basename(ctx.fh.path).split('.').slice(1))

    # for each adapter, compile the file's contents
    # (move to `setup_compile` method below for further explanation)
    
    # this should be wrapped as a pattern
    fn = (m, adapter, cb) ->
      @setup_compile(m, adapter)
        .catch((err) -> cb(err, null))
        .then((nm) -> cb(null, nm))

    async.inject ctx.adapters, ctx, fn.bind(@), (err, res) ->
      if err then return deferred.reject(err)
      deferred.resolve(res)

    return deferred.promise

  # this method represents a single compile pass on a file. since roots
  # can handle multipass compilation, this could be called more than once.
  
  setup_compile: (ctx, adapter) ->
    deferred = Q.defer()

    # make the adapter configurable by extensions
    # and bump the index once for each compile pass.
    ctx.adapter = adapter
    ctx.index++

    @hook('compile', ctx)
      .then(@compile_single.bind(@))
      .catch(deferred.reject)
      .done(deferred.resolve)

    return deferred.promise

  compile_single: (ctx) ->
    deferred = Q.defer()

    # put in work (https://cloudup.com/cNORDD98uFh)
    ctx.adapter.compile ctx.fh, ctx.fh.locals(), (err, compiled) =>
      if err then return deferred.reject(err)

      ctx.fh.contents = compiled

      @hook('after', ctx)
        .then(@write_file)
        .catch(deferred.reject)
        .done(deferred.resolve)

    return deferred.promise

  write_file: (ctx) ->
    ctx.fh.write(ctx.contents)
    return ctx

  ###*
   * Copies a file into the output folder. Symlinks in dev mode.
   * @param {string} file - path to a file
   * @param {function} cb - called when finished
   * @uses Project.mode
   * @todo this is a sync method and doesn't need a callback
  ###

  copy: (file, cb) ->
    destination = output_path(file)
    extname = path.extname(file).slice(1)
    compressed_extensions = ['html', 'css', 'js']

    if roots.project.mode == 'dev'
      symlink_file(file, destination) unless fs.existsSync(destination)
    else if compressed_extensions.indexOf(extname) > 0 && roots.project.conf('compress')
      compress_and_copy_file(file, destination)
    else
      copy_file(file, destination)

    cb()

module.exports = Compiler

#
# @api private
#

###*
 * Given a list of file extensions, return matching adapters that will
 * compile a file with the extensions provided
 * @param {array} extensions - array of strings listing extensions, no dot.
 * @return {array} array of adapters that can be used to compile the file
 * @private
###

get_adapters_by_extension = (extensions) ->
  matching_adapters = []
  extensions.reverse().forEach (ext) =>
    for key of adapters
      if adapters[key].settings.file_type == ext
        matching_adapters.push(adapters[key])

  return matching_adapters

###*
 * Symlinks a given file to the given destination
 * @param  {string} file
 * @param  {string} destination
 * @return {null}
 * @private
###

symlink_file = (file, destination) ->
  file_path = path.relative(path.dirname(destination), file)
  fs.symlinkSync(file_path, destination)
  roots.print.debug "symlinked #{file.replace(roots.project.rootDir, '')}"

###*
 * Compresses and copies a given file to the given destination
 * @param  {string} file
 * @param  {string} destination
 * @return {null}
 * @private
###

compress_and_copy_file = (file, destination) ->
  extname = path.extname(file).slice(1)
  write_content = fs.readFileSync(file, 'utf8')
  write_content = compress(write_content, extname)
  fs.writeFileSync(destination, write_content)
  roots.print.debug "compressed and copied #{file.replace(roots.project.rootDir, '')}"

###*
 * Copies a given file to the given destination
 * @param  {string} file
 * @param  {string} destination
 * @return {null}
 * @private
 * @todo Run the file copy operations as async (use ncp)
###

copy_file = (file, destination) ->
  shell.cp('-f', file, destination)
  roots.print.debug "copied #{file.replace(roots.project.rootDir, '')}"
