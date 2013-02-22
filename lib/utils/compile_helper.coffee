path = require 'path'
fs = require 'fs'
js_yaml = require 'js-yaml'
_ = require 'underscore'
fleck = require 'fleck'
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
    compile_dynamic_content.call(this)

    # layout handling
    set_layout.call(this) if @target_extension == 'html'

  # extra locals (like yield) can be added here
  locals: (extra) ->
    options.locals.path = @export_path # add path as an automatic local variable

    for key, value of extra
      options.locals[key] = value

    add_dynamic_variables.call(this, extra) if @dynamic_locals

    return options.locals

  write: (write_content) ->
    write_content = @compress(write_content) if options.compress
    fs.writeFileSync @export_path, write_content
    # delete options.locals.post
    global.options.debug.log "compiled #{path.basename(@file)}"

  compress: (write_content) ->
    require('../utils/compressor')(write_content, @target_extension)

# 
# @api private
# 

# uses the default layout unless overridden in app settings, creates
# layout path and contents variables
set_layout = ->
  @layout ?= options.layouts.default
  
  for file, layout_path of options.layouts
    @layout = layout_path if @file == file

  @layout_path = path.join(process.cwd(), options.folder_config.views, @layout)
  @layout_contents = fs.readFileSync @layout_path, 'utf8'

# parses yaml front matter, creates local variables that will hold the
# front matter and content, sets layout if present, removes front matter
# from content for parsing
compile_dynamic_content = ->
  yaml_matcher = /^---\s*\n([\s\S]*?)\n?---\s*\n?/
  front_matter_string = @file_contents.match(yaml_matcher)

  if front_matter_string
    @plural_name = @file.replace(process.cwd(),'').match(/\/(.*?)\//)[1]
    options.locals.site ?= {}
    options.locals.site[@plural_name] ?= []
    @dynamic_locals = {}

    front_matter = js_yaml.safeLoad(front_matter_string[1], { filename: @file })
    @dynamic_locals[k] = v for k,v of front_matter
  
    if _.pluck(front_matter, 'layout')
      @layout = front_matter.layout
      @dynamic_locals.url = @file.replace(process.cwd(), '').replace(/\..*?$/, '.html')

    @file_contents = @file_contents.replace yaml_matcher, ''

# adds front matter variables to a 'post' local for 
# dynamic layouts, adds the compiled content to the post's local
# and pushes it to the locals.sites array
add_dynamic_variables = (extra) ->
  options.locals.post = @dynamic_locals
  if extra? and extra.yield?
    @dynamic_locals.content = extra.yield
    options.locals.site[@plural_name].push(@dynamic_locals)