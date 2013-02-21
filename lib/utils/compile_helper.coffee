path = require 'path'
fs = require 'fs'
js_yaml = require 'js-yaml'
_ = require 'underscore'
output_path = require './output_path'

# this class' purpose is to resolve and hold on to all the file
# paths and file contents necessary to compile the file.

module.exports = class CompileHelper

  constructor: (@file) ->
    options = global.options

    @export_path = output_path(@file)
    @extension = path.extname(@file).slice(1)
    @target_extension = path.extname(@export_path).slice(1)
    @file_contents = fs.readFileSync(@file, 'utf8')

    # dynamic content handling
    yaml_matcher = /^---\s*\n([\s\S]*?)\n?---\s*\n?/
    front_matter_string = @file_contents.match(yaml_matcher)

    if front_matter_string
      # set up variables
      options.locals.site = []
      @dynamic_locals = {}

      front_matter = js_yaml.safeLoad(front_matter_string[1], { filename: @file })
      @dynamic_locals[k] = v for k,v of front_matter
      options.locals.post = @dynamic_locals
  
      @layout = front_matter.layout if _.pluck(front_matter, 'layout')
      @file_contents = @file_contents.replace yaml_matcher, ''

    # layout handling
    if @target_extension == 'html'
      @layout ?= options.layouts.default
      
      for file, layout_path of options.layouts
        @layout = layout_path if @file == file

      @layout_path = path.join(process.cwd(), options.folder_config.views, @layout)
      @layout_contents = fs.readFileSync @layout_path, 'utf8'

  # extra locals (like yield) can be added here
  locals: (extra) ->
    # add path as an automatic local variable
    options.locals.path = @export_path
    for key, value of extra
      options.locals[key] = value

    # add compiled content to locals for dynamic templates
    if @dynamic_locals and extra? and extra.yield?
      @dynamic_locals.content = extra.yield.trim()
      options.locals.site.push(@dynamic_locals)
      delete options.locals.post

    return options.locals

  write: (write_content) ->
    write_content = @compress(write_content) if options.compress
    fs.writeFileSync @export_path, write_content
    global.options.debug.log "compiled #{path.basename(@file)}"
    console.log options.locals.site

  compress: (write_content) ->
    require('../utils/compressor')(write_content, @target_extension)
