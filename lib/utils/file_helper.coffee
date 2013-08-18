path = require("path")
fs = require("fs")
_ = require("underscore")
roots = require("../index")
output_path = require("./output_path")
yaml_parser = require("./yaml_parser")

class FileHelper
  ###*
   * [constructor description]
   * @param {[type]} file [description]
   * @return {undefined}
   * @constructor
  ###
  constructor: (file) ->
    # set paths
    @path = file
    @contents = fs.readFileSync(file, 'utf8')
    @export_path = output_path(file)
    @extension = path.basename(@path).split('.')[1]
    @target_extension = path.basename(@export_path).split('.')[1]
    return

  ###*
   * [parse_dynamic_content description]
   * @return {[type]} [description]
   * @public
   * @uses set_paths
  ###
  parse_dynamic_content: ->
    front_matter_string = yaml_parser.match(@contents)
    if front_matter_string

      # set up variables
      @category_name = @path.replace(roots.project.rootDir, '').split(path.sep)[1]
      roots.project.locals.site ?= {}
      roots.project.locals.site[@category_name] ?= []
      @dynamic_locals = {}

      # load variables from front matter
      front_matter = yaml_parser.parse(@contents,
        filename: @file
      )
      for k of front_matter
        @dynamic_locals[k] = front_matter[k]

      # if layout is present, set the layout and single post url
      if front_matter.layout
        @layout_path = path.resolve(path.dirname(@path), front_matter.layout)
        @layout_contents = fs.readFileSync(@layout_path, "utf8")
        @dynamic_locals.url = @path.replace(roots.project.rootDir, '').replace(/\..*$/, ".html")

      # remove the front matter
      @contents = @contents.replace(front_matter_string[0], '')
    else
      false

  ###*
   * Sets the layout path and contents properties
   * @public
   * @uses set_paths, FileHelper.parse_dynamic_content
  ###
  set_layout: ->
    # make sure a layout actually has to be set
    layouts_set = Object.keys(roots.project.layouts).length > 0
    return false if @dynamic_locals || !layouts_set

    # pull the default layout initially
    layout = roots.project.cfg 'layouts.default'
    rel_file = path.relative(roots.project.path('views'), @path)

    # if there's a custom override, use that instead
    layout = roots.project.layouts[key] for key of roots.project.layouts if key is rel_file

    # no match
    return false if not layout?

    # set the layout path and contents
    @layout_path = path.join(roots.project.path('views'), layout)
    @layout_contents = fs.readFileSync(@layout_path, "utf8")

  ###*
   * Push the front matter variables and content for dynamic content
   * as locals so they are available in html templates
   * @param {String} contents - compiled contents
  ###
  set_dynamic_locals: ->
    @dynamic_locals.contents = @contents
    roots.project.locals.site[@category_name].push(@dynamic_locals)

  ###*
   * [locals description]
   * @param {[type]} extra [description]
   * @return {[type]} [description]
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
   * @return {[type]} [description]
   * @public
  ###
  write: (content) ->

    # if content is passed in, write that
    @contents = content if content

    # if dynamic and no layout, don't write
    if @dynamic_locals and not @dynamic_locals.layout

      # if dynamic with content, add the compiled content to the locals
      if @contents isnt ''
        category = roots.project.locals.site[@category_name]
        category[category.length - 1].content = @contents

      # don't write the file
      roots.print.debug "processed " + @path.replace(roots.project.rootDir, '')
      return false

    # write it
    fs.writeFileSync @export_path, @contents
    roots.print.debug "compiled " + @path.replace(roots.project.rootDir, '')

module.exports = FileHelper
