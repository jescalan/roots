path = require 'path'
fs = require 'fs'
debug = require '../debug'

# this class is absurd. its purpose is to resolve and
# hold on to all the file paths and file contents necessary to
# compile the file. this looks messy, but it's what keeps
# the actual compilers clean

module.exports = class CompileHelper

  constructor: (@file, @options, @name) ->

    @current_directory = path.normalize process.cwd()
    html_file = @options.file_types.html.indexOf(@name) > -1
    css_file = @options.file_types.css.indexOf(@name) > -1
    js_file = @options.file_types.js.indexOf(@name) > -1

    # if we're working with file that will compile to html
    if html_file
      @target_extension = 'html'
      base_folder = @options.folder_config.views

      # deal with layouts
      @layout = @options.layouts.default
      for file, layout of @options.layouts
        @layout = layout if file == @file

      @layout_path = path.join @current_directory, base_folder, @layout # check for customs
      @layout_contents = fs.readFileSync @layout_path, 'utf8'

    # if we're working with file that will compile to css
    else if css_file
      @target_extension = 'css'
      base_folder = @options.folder_config.assets

    # if we're working with file that will compile to js
    else if js_file
      @target_extension = 'js'
      base_folder = @options.folder_config.assets

    # something really whack happened
    else
      throw "unsupported file extension: .#{@name}"

    @file_path = path.join @current_directory, base_folder, @file
    @file_contents = fs.readFileSync @file_path, 'utf8'
    @export_path = path.join @current_directory, 'public', path.dirname(@file), "#{path.basename @file, path.extname(@file)}.#{@target_extension}"
  
  # extra locals (like yield) can be added here
  locals: (extra) ->
    for key, value of extra
      @options.locals[key] = value
    return @options.locals

  write: (write_content) ->
    # @compress(write_content) if @options.compress
    fs.writeFileSync @export_path, write_content
    debug.log "compiled #{path.basename(@file)}"

  compress: (write_content) ->
    # this is where the file should be minified, compressed, etc
    # if that option is active
    # @target_extension is available so it's easy to tell how to compress

    # UglifyJS = require 'uglify-js2'
    # UglifyJS.minify("/path/to/file.js")
    # this needs to take text input rather than a file path. yech.
    # we have to do it the long way then:
    # https://github.com/mishoo/UglifyJS2

    # csso = require 'csso'
    # csso.justDoIt(css-content)
