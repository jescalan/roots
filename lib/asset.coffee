path = require 'path'
fs = require 'fs'
_ = require 'underscore'
output_path = require './utils/output_path'
yaml_parser = require './utils/yaml_parser'
roots = require './roots'
EventEmitter = require('events').EventEmitter
adapters = require("./adapters")

class Asset extends EventEmitter
  ###*
   * [constructor description]
   * @param {String} file [description]
   * @return {undefined}
   * @constructor
  ###
  constructor: (file) ->
    # set paths
    @path = file
    @contents = fs.readFileSync(@path, 'utf8')


    @setOutputPath()
    @addWatcher()
    roots.print.debug "setup Asset: #{@}"
    return

  ###*
   * Sets Asset.relativePath, Asset.outputPath (the path that this Asset will
     compile to), Asset.outputExtension, and Asset.extension.
   * @uses Asset.path
  ###
  setPaths: ->
    @relativePath = @path.replace roots.project.root_dir, ''
    @extension = path.basename(file).split('.')[1] # this should take the *first* extension only
    
    # dump views/assets to public
    # I'm worried about the second replace call...
    @outputPath = path.join(
      file.replace(roots.project.root_dir, roots.project.public_dir)
    ).replace(
      new RegExp("#{roots.project.views_dir}|#{roots.project.assets_dir}"), ''
    )
    
    # swap extension if needed
    @outputPath = @outputPath.replace(new RegExp("\\.#{extension}.*"), '.' + adapters[extension].settings.target)  if adapters[extension]
    @outputPath = path.join roots.project.root_dir, @outputPath

    @outputExtension = path.basename(@outputPath).split('.')[1]

  ###*
   * Updates the Asset.contents and (if Asset.contents has really changed) emits an
     event to notify listeners that this Asset has been modified.
   * @return {undefined}
   * @fires Compiler#modified
  ###
  modified: ->
    old_contents = @contents
    @contents = fs.readFileSync(@path, 'utf8')
    if @contents is old_contents
      roots.print.debug "#{@} wasn't really modified"
      return
    roots.print.debug "#{@} was modified"

    # for Asset graph, this part would loop through all the Assets in
    # Asset.dependents, compiling each of them. Right now, it just emits an
    # event that triggers a recompile of all the Assets
    @emit 'modified'

  addWatcher: (cb) ->
    monocle.watchFiles(
      files: [@path]
      listener: @modified
      complete: cb
    )

  ###*
   * An array of all Assets that rely on this Asset. These are the files that
     need to be recompiled when this one is modified.
   * When the Asset graph is working, this will hold only files that are
     really dependent on this one. Right now, this holds all Assets.
   * @type {Array}
  ###
  dependents: []

  ###*
   * Is one of:
   * uncompiled: hasn't been compiled
   * copied: was copied to Project.public_dir and doesn't need to be
     recompiled unless the Asset itself is modified.
   * symlinked: was symlinked to Project.public_dir and doesn't need to be
     recompiled even if the file is modified.
   * compiled: some transformation was applied while being compiled, and when
     this Asset, or one of its dependencies is modified, it must be recompiled
   * @type {String}
  ###
  status: 'uncompiled'

  ###*
   * Determines what type of compiling needs to be done, and (if necessary)
     compiles the asset to Asset.outputPath
   * @return {undefined}
  ###
  compile: ->
    if @status is 'symlinked'
      return #

    roots.print.debug "#{@status} #{@}"
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
      @category_name = @path.replace(roots.project.root_dir, "").split(path.sep)[1]
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
        @layout_contents = fs.readFileSync(@layout_path, 'utf8')
        @dynamic_locals.url = @path.replace(roots.project.root_dir, '').replace(/\..*$/, '.html')
      
      # add to global locals (hah)
      options.locals.site[@category_name].push @dynamic_locals
      
      # remove the front matter
      @contents = @contents.replace(front_matter_string[0], '')
    else
      false

  ###*
   * [set_layout description]
   * @public
   * @uses set_paths, Asset.parse_dynamic_content
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
      @layout_path = path.join(roots.project.root_dir, options.folder_config.views, layout)
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
   * write Asset.contents to Asset.path
   * @return {[type]} [description]
   * @public
  ###
  write: ->
    # if dynamic and no layout, don't write
    if @dynamic_locals and not @dynamic_locals.layout
      
      # if dynamic with content, add the compiled content to the locals
      if @contents isnt ""
        category = options.locals.site[@category_name]
        category[category.length - 1].content = @contents
      
      # don't write the file
      roots.print.debug "processed #{@}"
      return false
    
    # write it
    fs.writeFileSync @export_path, @contents
    global.options.debug.log "compiled " + @path.replace(process.cwd(), "")

  toString: ->
    # more useful than `[object Object]`
    return @relativePath

module.exports = Asset
