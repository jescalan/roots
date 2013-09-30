path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
EventEmitter = require('events').EventEmitter
_ = require 'underscore'
Q = require 'q'
async = require 'async'

adapters = require './adapters'
compress = require './utils/compressor'
output_path = require './utils/output_path'
FileHelper = require './utils/file_helper'
roots = require './index'

class DynamicContentExtension

  compile_hook: (deferred) ->
    intermediate = (@adapters.length - @index - 1 > 0)
    @fh.parse_dynamic_content() unless intermediate
    deferred.resolve()

class LayoutsExtension

  after_hook: (deferred) ->
    if !(@adapters.length - @index - 1 > 0)
      process_layout.call @, @fh, @adapter, (contents) =>
        @fh.write(contents)
        deferred.resolve()

class Compiler extends EventEmitter

  # decorator pattern
  # http://coffeescriptcookbook.com/chapters/design_patterns/decorator
  constructor: ->
    @extensions = [new DynamicContentExtension, new LayoutsExtension]

  ###*
   * Emits an event to notify listeners that everything is compiled
   * @fires Compiler#finished
  ###

  finish: ->
    @emit 'finished'

  # register an extension
  
  register: (ext) ->
    @extensions.push(ext)

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
    
    fn = (m,ext,cb) =>
      @hook_single(ext, name, ctx)
        .then (nm) -> cb(null, nm || m)

    async.inject @extensions, ctx, fn, (err, res) ->
      if err then return deferred.reject(err)
      deferred.resolve(res)

    return deferred.promise

  hook_single: (ext, name, ctx) ->
    deferred = Q.defer()

    hook = ext["#{name}_hook"]
    if hook then hook.call(ctx, deferred) else deferred.resolve()
    
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
      index: 1

    # the 'hook' method allows extensions to be incorporated into the
    # roots compile process. for maximum flexibility, extensions can
    # edit the context in any way, multiple extensions can be called
    # on the same hook, and any extension can run sync or async.
    # see `hook` above for further explanation

    @hook('before', ctx)
      .then(@compile_each.bind(@))
      .catch (err) -> @emit('error', err)
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
    # also that `null` should be actual error handling
    fn = (m, adapter, cb) ->
      @setup_compile(m, adapter)
        .then (nm) ->
          cb(null, nm)

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
      .then(deferred.resolve)

    return deferred.promise

  compile_single: (ctx) ->
    deferred = Q.defer()

    # put in work (https://cloudup.com/cNORDD98uFh)
    ctx.adapter.compile ctx.fh, ctx.fh.locals(), (err, compiled) =>
      if err then return deferred.reject(err)

      ctx.compiled_content = compiled
      ctx.fh.contents = compiled

      @hook('after', ctx)
        .then(deferred.resolve)

    return deferred.promise

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
 * Compliles a given file into it's layout.
 * @param {FileHelper} fh - file helper for a given file
 * @param {Adapter} adapter - adapter that can be used to compile the given file
 * @param {Function} cb - callback when finished
 * @private
###

compile_into_layout = (fh, adapter, cb) ->
  layout_file =
    contents: fh.layout_contents
    path: fh.layout_path

  adapter.compile layout_file, fh.locals(content: fh.contents), (err, layout) =>
    if err then return @emit('error', err)
    cb(layout)

###*
 * If necessary, sets up layout information and compiles content into
 * it's template. Returns the content ready to write.
 * @param  {FileHelper} fh - FileHelper instance
 * @param  {Adapter} adapter - Adapter needed to compile
 * @return {string} content to write
 * @private
###

process_layout = (fh, adapter, cb) ->
  fh.set_layout() if fh.target_extension is 'html'
  fh.set_dynamic_locals() if !!fh.dynamic_locals
  return compile_into_layout.call(@, fh, adapter, cb) if fh.layout_path
  cb(fh.contents)

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
