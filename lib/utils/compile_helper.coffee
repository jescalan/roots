path = require 'path'
fs = require 'fs'
adapters = require '../adapters'

# this class is absurd. its purpose is to resolve and
# hold on to all the file paths and file contents necessary to
# compile the file. this looks messy, but it's necessary and is
# what keeps the actual compilers so clean

module.exports = class CompileHelper

  constructor: (@file) ->

    options = global.options
    @extension = path.extname(@file).slice(1)
    @current_directory = path.normalize process.cwd()

    @target_extension = adapters[@extension].settings.target

    # handling for layouts
    if @target_extension == 'html'
      @layout = options.layouts.default
      for file, layout_path of options.layouts
        @layout = layout_path if @file == file
      @layout_path = path.join @current_directory, options.folder_config.views, @layout
      @layout_contents = fs.readFileSync @layout_path, 'utf8'

    @file_path = path.join @current_directory, @file
    @file_contents = fs.readFileSync @file_path, 'utf8'
    @export_path = path.join @current_directory, 'public', path.dirname(@file).replace(/^assets|views/,''), "#{path.basename(@file, path.extname(@file))}.#{@target_extension}"
  
  # extra locals (like yield) can be added here
  locals: (extra) ->
    for key, value of extra
      options.locals[key] = value
    return options.locals

  write: (write_content) ->
    write_content = @compress(write_content) if options.compress
    fs.writeFileSync @export_path, write_content
    global.options.debug.log "compiled #{path.basename(@file)}"

  compress: (write_content) ->
    require('../utils/compressor')(write_content, @target_extension)