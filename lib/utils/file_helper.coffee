path = require("path")
fs = require("fs")
_ = require("underscore")
output_path = require("./output_path")
yaml_parser = require("./yaml_parser")

class Asset
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
   * An array of all Assets that rely on this Asset. These are the files that
     need to be recompiled when this one is modified.
   * @type {Array}
  ###
  dependants: []

  toString: ->
    # more useful than `[object Object]`
    return @path

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
      @category_name = @path.replace(process.cwd(), "").split(path.sep)[1]
      options.locals.site ?= {}
      options.locals.site[@category_name] ?= []
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
        @dynamic_locals.url = @path.replace(process.cwd(), "").replace(/\..*$/, ".html")
      
      # add to global locals (hah)
      options.locals.site[@category_name].push @dynamic_locals
      
      # remove the front matter
      @contents = @contents.replace(front_matter_string[0], "")
    else
      false

  ###*
   * [set_layout description]
   * @public
   * @uses set_paths, FileHelper.parse_dynamic_content
  ###
  set_layout: ->
    # make sure a layout actually has to be set
    layouts_set = Object.keys(global.options.layouts).length > 0
    if layouts_set and not @dynamic_locals
      
      # pull the default layout initially
      layout = options.layouts.default
      rel_file = path.relative(options.folder_config.views, @path)
      
      # if there's a custom override, use that instead
      for key of options.layouts
        layout = options.layouts[key] if key is rel_file

      # no match
      if not layout? then return false
      
      # set the layout path and contents
      @layout_path = path.join(process.cwd(), options.folder_config.views, layout)
      @layout_contents = fs.readFileSync(@layout_path, "utf8")
    else
      false

  ###*
   * [locals description]
   * @param {[type]} extra [description]
   * @return {[type]} [description]
   * @public
  ###
  locals: (extra) ->
    locals = _.clone(global.options.locals)
    
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
  write: () ->
    # if dynamic and no layout, don't write
    if @dynamic_locals and not @dynamic_locals.layout
      
      # if dynamic with content, add the compiled content to the locals
      if @contents isnt ""
        category = options.locals.site[@category_name]
        category[category.length - 1].content = @contents
      
      # don't write the file
      global.options.debug.log "processed " + @path.replace(process.cwd(), "")
      return false
    
    # write it
    fs.writeFileSync @export_path, @contents
    global.options.debug.log "compiled " + @path.replace(process.cwd(), "")

module.exports = Asset
