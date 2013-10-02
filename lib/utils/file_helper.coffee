path = require("path")
fs = require("fs")
_ = require("underscore")
roots = require("../index")
output_path = require("./output_path")
yaml_parser = require("./yaml_parser")

class FileHelper

  ###*
   * [constructor description]
   * @param {string} file - path to a file
   * @constructor
  ###

  constructor: (file) ->
    @path = file
    @relative_path = @path.replace(process.cwd(),'')
    @contents = fs.readFileSync(file, 'utf8')
    @export_path = output_path(file)
    @extension = path.basename(@path).split('.')[1]
    @target_extension = path.basename(@export_path).split('.')[1]
    return

  ###*
   * [locals description]
   * @param {Object} extra - any extra properties to be added to locals
   * @return {Object} - modified locals object
   * @public
  ###

  locals: (extra) ->
    locals = _.clone(roots.project.locals)

    # add path variable
    locals.path = @export_path

    # add any extra locals
    for key of extra
      locals[key] = extra[key]

    # add dynamic locals if needed
    if @dynamic_locals
      locals.post = @dynamic_locals
      @dynamic_locals.content = extra.yield  if extra and extra.hasOwnProperty("yield")
    locals

  ###*
   * write FileHelper.contents to FileHelper.path
   * @return {string} content - string of content to write
   * @public
  ###

  write: (content) ->
    # if content is passed in, write that
    @contents = content if content

    # if dynamic and no layout, don't write
    if @dynamic_locals and not @dynamic_locals.layout

      # if dynamic with content, add the compiled content to the locals
      if @contents isnt ''
        @local_pointer[@local_pointer.length - 1].contents = @contents

      # don't write the file
      roots.print.debug "processed " + @path.replace(roots.project.rootDir, '')
      return false

    # write it
    fs.writeFileSync @export_path, @contents
    roots.print.debug "compiled " + @path.replace(roots.project.rootDir, '')

module.exports = FileHelper
