path = require 'path'
fs = require 'fs'
_ = require 'underscore'
output_path = require './output_path'
yaml_parser = require './yaml_parser'

# this class' purpose is to resolve and hold on to all the file
# paths and file contents necessary to compile the file.

module.exports = class CompileHelper

  constructor: (@file, strip) ->
    options = global.options

    @export_path = output_path(@file, strip)
    @extension = path.extname(@file).slice(1)
    @target_extension = path.extname(@export_path).slice(1)
    @file_contents = fs.readFileSync(@file, 'utf8')

    compile_dynamic_content.call(this)
    set_layout.call(this) if @target_extension == 'html'

  # extra locals (like yield) can be added here
  locals: (extra) ->
    options.locals.path = @export_path
    options.locals[key] = value for key, value of extra
    add_dynamic_variables.call(this, extra) if @dynamic_locals
    return options.locals

  write: (write_content) ->
    # hook here to not write posts with no layout
    write_content = @compress(write_content) if options.compress
    fs.writeFileSync @export_path, write_content
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
  front_matter_string = yaml_parser.match(@file_contents)

  if front_matter_string

    # set up variables
    @category_name = @file.replace(process.cwd(),'').split(path.sep)[1]
    options.locals.site ?= {}
    options.locals.site[@category_name] ?= []
    @dynamic_locals = {}

    # load variables from front matter
    front_matter = yaml_parser.parse @file_contents, { filename: @file }
    @dynamic_locals[k] = v for k,v of front_matter
    
    # if layout is present, set the layout and single post url
    if _.pluck(front_matter, 'layout')
      @layout = front_matter.layout
      @dynamic_locals.url = @file.replace(process.cwd(), '').replace(/\..*?$/, '.html')

    # remove the front matter
    @file_contents = @file_contents.replace front_matter_string[0], ''

# adds front matter variables to a 'post' local for 
# dynamic layouts, adds the compiled content to the post's local
# and pushes it to the locals.sites array
add_dynamic_variables = (extra) ->
  options.locals.post = @dynamic_locals
  if extra? and extra.yield?
    @dynamic_locals.content = extra.yield
    options.locals.site[@category_name].push(@dynamic_locals)