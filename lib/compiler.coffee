path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
EventEmitter = require('events').EventEmitter
adapters = require './adapters'
compress = require './utils/compressor'
output_path = require './utils/output_path'
_ = require 'underscore'
file_helper = require './utils/file_helper'

class Compiler extends EventEmitter
  finish: ->
    @emit 'finished'

  compile: (file, cb) ->
    matching_adapters = get_adapters_by_extension(
      path.basename(file).split('.').slice(1)
    )
    fh = file_helper(file)
    matching_adapters.forEach (adapter, i) =>
      intermediate = (matching_adapters.length - i - 1 > 0)

      unless intermediate
        fh.parse_dynamic_content()
        fh.set_layout()

      adapter.compile fh, (err, compiled) =>
        if err
          return @emit('error', err)

        pass_through = ->
          fh.contents = compiled

        write = (content) ->
          fh.write(content)
          cb()

        write_file = ->
          if fh.layout_path
            compile_into_layout fh, adapter, compiled, (compiled_with_layout) ->
              write compiled_with_layout
          else if typeof compiled is 'function'
            write compiled(fh.locals())
          else
            write compiled

        if intermediate
          return pass_through()
        else
          return write_file()

  copy: (file, cb) ->
    # TODO: Run the file copy operations as async (ncp)
    destination = output_path(file)
    extname = path.extname(file).slice(1)
    types = ['html', 'css', 'js']
    if types.indexOf(extname) > 0
      write_content = fs.readFileSync(file, 'utf8')
      if global.options.compress
        write_content = compress(write_content, extname)
      fs.writeFileSync destination, write_content
    else
      shell.cp '-f', file, destination
    options.debug.log 'copied ' + file.replace(process.cwd(), '')
    cb()


module.exports = Compiler

plugin_path = path.join(process.cwd() + '/plugins')
plugins = fs.existsSync(plugin_path) and shell.ls(plugin_path)

# @api private
get_adapters_by_extension = (extensions) ->
  matching_adapters = []
  extensions.reverse().forEach (ext) ->
    for key of adapters
      if adapters[key].settings.file_type is ext
        matching_adapters.push adapters[key]

  return matching_adapters

compile_into_layout = (fh, adapter, compiled, cb) ->
  file_mock =
    path: fh.layout_path
    contents: fh.layout_contents

  if typeof compiled isnt 'function'
    console.log 'html compilers must output a function'

  adapter.compile file_mock, (err, layout) ->
    page = compiled(fh.locals())
    rendered_template = layout(fh.locals('yield': page))
    cb rendered_template
