path = require 'path'
fs = require 'fs'
_ = require 'underscore'
cp = require 'cp'
yaml_parser = require './utils/yaml_parser'
roots = require './index'
EventEmitter = require('events').EventEmitter

class Asset extends EventEmitter
  ###*
   * [constructor description]
   * @param {String} file The full path to the Asset. 
   * @return {undefined}
   * @constructor
  ###
  constructor: (file) ->
    adapters = require("./adapters") # blah! deps

    # set paths
    @path = file
    @contents = fs.readFileSync(@path, 'utf8')

    @setOutputPath()
    @addWatcher()
    
    @on 'compile error', (err) ->
      roots.print.error err
      add_error_messages.call @, err, @finish

    roots.print.debug "setup Asset: #{@}"
    return

  ###*
   * Is one of:
   * uncompiled: hasn't been compiled
   * symlinked: was symlinked to Project.path('public') and doesn't need to be
     recompiled even if the file is modified.
   * compiled: some transformation was applied while being compiled, and when
     this Asset, or one of its dependencies is modified, it must be recompiled
     (same as being copied)
   * @type {String}
  ###
  status: 'uncompiled'

  ###*
   * the full path to the source file
   * @type {String}
   * @private
  ###
  path: ''

  ###*
   * Path to the source file, relative to Project.rootDir
   * @type {String}
  ###
  relativePath: ''

  ###*`
   * The full path to the file that is being served by the server.
   * @type {String}
   * @private
  ###
  outputPath: ''

  ###*
   * An array of extensions that the file has. Extensions are read right to
     left because that represents the order that it will be compiled. For
     example, the extensions of `example.jade.erb` are `['erb', 'jade']` and
     the file will be compiled with `erb` first, and then `jade`.
   * @type {Array}
  ###
  extensions: []

  ###*
   * The extension that the outputted file will have. For example, "coffee"
     compiles to "js", so "js" is the outputExtension.
   * @type {String}
  ###
  outputExtension: ''

  ###*
   * An array of all Assets that rely on this Asset. These are the files that
     need to be recompiled when this one is modified.
   * When the Asset graph is working, this will hold only files that are
     really dependent on this one. Right now, this holds all Assets that
     aren't ignored.
   * @type {Array}
  ###
  dependents: []

  ###*
   * The contents of the source file.
   * @type {String}
  ###
  contents: ''

  ###*
   * The compiled contents of the Asset.
   * @type {String}
  ###
  outputContents: ''

  ###*
   * An array of all the adapters that are needed to compile the file, in the
     order in which they are applied.
   * @type {Array}
  ###
  adapters: []

  ###*
   * Sets Asset.relativePath, Asset.outputPath (the path that this Asset will
     compile to), Asset.outputExtension, and Asset.extension.
   * @uses Asset.path
  ###
  setPaths: ->
    @relativePath = @path.replace roots.project.rootDir, ''
    @extensions = path.basename(file).split('.')[1..].reverse()
    
    # dump views/assets to public
    # I'm worried about the second replace call...
    @outputPath = path.join(
      file.replace(roots.project.rootDir, roots.project.path('public'))
    ).replace(
      new RegExp("#{roots.project.path 'views'}|#{roots.project.path 'assets'}"),
      ''
    )
    
    # swap extension if needed
    @outputPath = @outputPath.replace(new RegExp("\\.#{extension}.*"), '.' + adapters[extension].settings.target)  if adapters[extension]
    @outputPath = path.join roots.project.rootDir, @outputPath

    @outputExtension = path.basename(@outputPath).split('.')[1]


  ###*
   * Updates the Asset.contents and (if Asset.contents has really changed)
     emits an event to notify listeners that this Asset has really been
     modified.
   * @return {undefined}
   * @fires Asset#modified
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
   * Determines what type of compiling needs to be done, and (if necessary)
     compiles the asset to Asset.outputPath
   * @return {undefined}
   * @fires Asset#compiled
   * @async
  ###
  compile: ->
    if @status is 'symlinked'
      return # we don't need to do anything if it's symlinked

    # if there's no real compiling to do
    if @adapters.length is 0
      if roots.project.mode is 'dev'
        fs.symlink @path, @outputPath, =>
          @status = 'symlinked'
          roots.print.debug "symlinked #{@}"
          # this is the first (and only time) time that symlink has been made,
          # so the browser will need to reload
          @emit 'compiled'
      else if roots.project.mode is 'build'
        cp @path, @outputPath, =>
          @status = 'compiled'
          roots.print.debug "copied #{@}"
          # we already know it has been modified, so the browser will need to
          # reload
          @emit 'compiled'
      return

    oldOutputContents = @outputContents

    # actually compile it

    # loop through the adapters, sending the result of the each one into the
    # next

    # make sure that compiling actually changed something. quite often, small
    # stylistic changes have no impact on the compiled file, and would result
    # in an unneeded reload
    if @outputContents isnt oldOutputContents
      fs.writeFile @outputPath, @outputContents, =>
        @status = 'compiled'
        roots.print.debug "compiled #{@}"
        @emit 'compiled'
    else
      roots.print.debug "compiled #{@}, but it didn't change the output"

  ###*
   * [parse_dynamic_content description]
   * @return {[type]} [description]
   * @public
   * @uses setPaths
  ###
  parse_dynamic_content: ->
    front_matter_string = yaml_parser.match(@contents)
    if front_matter_string
      
      # set up variables
      @category_name = @path.replace(roots.project.rootDir, '').split(path.sep)[1]
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
        @dynamic_locals.url = @path.replace(roots.project.rootDir, '').replace(/\..*$/, '.html')
      
      # add to global locals (hah)
      options.locals.site[@category_name].push @dynamic_locals
      
      # remove the front matter
      @contents = @contents.replace(front_matter_string[0], '')
    else
      false

  ###*
   * [set_layout description]
   * @public
   * @uses setPaths, Asset.parse_dynamic_content
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
      @layout_path = path.join(roots.project.rootDir, options.folder_config.views, layout)
      @layout_contents = fs.readFileSync(@layout_path, 'utf8')
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
  #write: ->
  #  # if dynamic and no layout, don't write
  #  if @dynamic_locals and not @dynamic_locals.layout

  #    # if dynamic with content, add the compiled content to the locals
  #    if @contents isnt ''
  #      category = options.locals.site[@category_name]
  #      category[category.length - 1].content = @contents

  #    # don't write the file
  #    roots.print.debug "processed #{@}"
  #    return false

  #  # write it
  #  fs.writeFileSync @export_path, @contents
  #  global.options.debug.log 'compiled ' + @path.replace(process.cwd(), '')

  toString: ->
    # more useful than `[object Object]`
    return @relativePath

module.exports = Asset
