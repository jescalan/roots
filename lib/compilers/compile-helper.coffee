path = require 'path'
fs = require 'fs'
debug = require '../debug'

module.exports = class CompileHelper

  constructor: (@file, @options, @name) ->

    @current_directory = path.normalize process.cwd()

    @file_path = path.join @current_directory, @options.folder_config.views, @file
    @file_contents = fs.readFileSync @file_path, 'utf8'
    @layout_path = path.join @current_directory, @options.folder_config.views, @options.layouts.default # check for customs
    @layout_contents = fs.readFileSync @layout_path, 'utf8'

    # figure out what type of file will be exported
    if @options.file_types.html.indexOf(@name) > -1
      @target_extension = 'html'
    else if @options.file_types.css.indexOf(@name) > -1
      @target_extension = 'css'
    else if @options.file_types.js.indexOf(@name) > -1
      @target_extension = 'js'
    else
      console.log @options.file_types.html
      console.log @name
      throw 'unsupported file extension'

    # if a view file, drop it in public/, if an asset file, public/css/ or public/js/
    if @target_extension == 'html'
      @export_path = path.join @current_directory, 'public', path.dirname(@file), "#{path.basename @file, path.extname(@file)}.#{@target_extension}"
    else
      @export_path = path.join @current_directory, 'public', @target_extension, path.dirname(@file), "#{path.basename @file, path.extname(@file)}.#{@target_extension}"

  write: (write_content)->
    fs.writeFileSync @export_path, write_content
    debug.log "compiled #{path.basename(@file)}"
