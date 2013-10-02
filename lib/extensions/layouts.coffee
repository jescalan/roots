roots = require '../index'
path = require 'path'
fs = require 'fs'

class LayoutsExtension

  after_hook: (deferred) ->
    # only process layout on the last compile pass
    if @adapters.length > @index then return deferred.resolve(@)

    process_layout.call @, (err, contents) =>
      if err then return deferred.reject(err)
      @fh.contents = contents
      deferred.resolve(@)

  ###*
   * Push the front matter variables and content for dynamic content
   * as locals so they are available in html templates
   * @private
  ###

  set_dynamic_locals = ->
    @dynamic_locals.contents = @contents
    
    # get an array of folder the content is nested in
    nested_folders = @path.replace(roots.project.rootDir,'').split(path.sep)
    nested_folders.pop()
    nested_folders.shift()

    # make sure all folders are represented on the site object in locals
    roots.project.locals.site ?= {}
    tmp = roots.project.locals.site

    for folder, i in nested_folders
      tmp[folder] ?= []
      if i == nested_folders.length-1 then tmp[folder].push(@dynamic_locals)
      @local_pointer = tmp = tmp[folder]
  
  ###*
   * Sets the layout path and contents properties
   * @private
  ###

  set_layout = ->
    # make sure a layout actually has to be set
    layouts_set = Object.keys(roots.project.layouts).length > 0
    if @dynamic_locals || !layouts_set then return false 

    # pull the default layout initially
    layout = roots.project.conf 'layouts.default'
    rel_file = path.relative(roots.project.path('views'), @path)

    # if there's a custom override, use that instead
    layout = roots.project.layouts[key] for key of roots.project.layouts if key is rel_file

    # no match
    if not layout? then return false

    # set the layout path and contents
    @layout_path = path.join(roots.project.path('views'), layout)
    @layout_contents = fs.readFileSync(@layout_path, "utf8")

  ###*
   * compiles a file into its layout
   * @private
  ###
  compile_into_layout = (cb) ->
    layout_file = { contents: @fh.layout_contents, path: @fh.layout_path }
    @adapter.compile layout_file, @fh.locals(content: @fh.contents), (err, layout) =>
      if err then return cb(err, null)
      cb(null, layout)

  ###*
   * sets up a file to be compiled into its layout
   * @private
  ###
  process_layout = (cb) ->
    set_layout.call(@fh) if @fh.target_extension is 'html'
    set_dynamic_locals.call(@fh) if !!@fh.dynamic_locals
    return compile_into_layout.call(@, cb) if @fh.layout_path
    cb(null, @fh.contents)

module.exports = LayoutsExtension
