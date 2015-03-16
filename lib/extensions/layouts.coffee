require 'coffee-script'

roots = require '../index'
path = require 'path'
fs = require 'fs'
adapter_finder = require '../utils/adapter_finder'

class LayoutsExtension

  after_hook: (ctx, deferred) ->
    # only process layout on the last compile pass
    if ctx.adapters.length > ctx.index then return deferred.resolve(ctx)

    process_layout ctx, (err, contents) =>
      if err then return deferred.reject(err)
      ctx.fh.contents = contents
      # (deprecated) post.content
      ctx.fh.content = contents
      deferred.resolve(ctx)

  ###*
   * given a layout path, sets up appropriate locals on the
   * context object
   * @param {Object} fh - file helper object
   * @param {String} layout - path to the layout
   * @param {Boolean} resolved - is the layout resolved from the
   *                             view path, or set absolutely?
   * @public
  ###

  set_layout_locals = (fh, layout, resolved) ->

    if resolved
      fh.layout_path = path.resolve(path.dirname(fh.path), layout)
    else
      fh.layout_path = path.join(roots.project.rootDir, roots.project.dirs.views, layout)

    fh.layout_contents = fs.readFileSync(fh.layout_path, "utf8")
    fh.layout_adapters = adapter_finder(path.basename(fh.layout_path).split('.').slice(1))

  set_layout_locals: set_layout_locals

  ###*
   * sets up a file to be compiled into its layout
   * @private
  ###

  process_layout = (ctx, cb) ->
    # why does this not work when required at the top?!
    DynamicContentExtension = require './dynamic_content'
    set_layout(ctx.fh) if ctx.fh.target_extension is 'html'
    (new DynamicContentExtension).set_dynamic_locals(ctx.fh) if !!ctx.fh.dynamic_locals
    return compile_into_layout(ctx, cb) if ctx.fh.layout_path
    cb(null, ctx.fh.contents)

  ###*
   * Sets the layout path and contents properties
   * @private
  ###

  set_layout = (fh) ->
    # make sure a layout actually has to be set
    layouts_set = Object.keys(roots.project.layouts).length > 0
    if fh.dynamic_locals || !layouts_set then return false

    # pull the default layout initially
    layout = roots.project.conf 'layouts.default'
    rel_file = path.relative(roots.project.path('views'), fh.path)

    # if there's a custom override, use that instead
    for key of roots.project.layouts
      if key is rel_file
        layout = roots.project.layouts[key]
        break

    # no match
    if not layout? then return false

    # set the layout path, adapter, and contents
    set_layout_locals(fh, layout)

  ###*
   * compiles a file into its layout
   * @private
  ###

  compile_into_layout = (ctx, cb) ->
    # (deprecated) post.content
    layout_file = {
      contents: ctx.fh.layout_contents,
      content: ctx.fh.layout_contents,
      path: ctx.fh.layout_path
    }
    ctx.fh.layout_adapters[0].compile layout_file, ctx.fh.locals(content: ctx.fh.contents), (err, layout) =>
      if err then return cb(err, null)
      cb(null, layout)

module.exports = LayoutsExtension
