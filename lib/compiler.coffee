path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
EventEmitter = require('events').EventEmitter
_ = require 'underscore'

adapters = require './adapters'
compress = require './utils/compressor'
output_path = require './utils/output_path'
FileHelper = require './utils/file_helper'
roots = require './index'

class Compiler extends EventEmitter

  ###*
   * Emits an event to notify listeners that everything is compiled
   * @fires Compiler#finished
  ###

  finish: ->
    @emit 'finished'

  ###*
   * Compiles a given file. Figures out how to compile based on extension, and
   * can handle multipass compiles if a file has multiple extensions.
   * @param {string} file - path to a file
   * @param {function} cb - executed when finished
  ###

  compile: (file, cb) ->
    fh = new FileHelper(file)

    # grab a compile adapter for each extension on the file
    extensions = path.basename(file).split('.').slice(1)
    matching_adapters = get_adapters_by_extension(extensions)

    # compile once for each adapter
    matching_adapters.forEach (adapter, i) =>

      # if true, this is not the last compile pass
      intermediate = (matching_adapters.length - i - 1 > 0)

      # front matter stays intact until the last compile pass
      fh.parse_dynamic_content() unless intermediate

      # put in work (https://cloudup.com/cNORDD98uFh)
      adapter.compile fh, fh.locals(), (err, compiled) =>
        return @emit('error', err) if err
        fh.contents = compiled
        return if intermediate

        # on the final pass, compile into layout if needed and write
        process_layout fh, adapter, (contents) ->
          fh.write(contents)
          cb()

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
    else if compressed_extensions.indexOf(extname) > 0 && global.options.compress
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
  fh.set_dynamic_locals() if !!fh.category_name
  return compile_into_layout(fh, adapter, cb) if fh.layout_path
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
