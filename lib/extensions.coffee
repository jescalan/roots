_ = require 'lodash'
compiled_ext = require './extensions/compiled'
static_ext = require './extensions/static'

###*
 * @class Extensions
 * @classdesc Responsible for managing roots extensions
 * @todo could this be an array with methods on it rather than a class?
###

class Extensions

  constructor: (@roots) ->
    @all = []
    @register [compiled_ext(), static_ext()]

  ###*
   * Registers roots extension(s) with your project. Tests each extension passed
   * to ensure it's the right type, then flips the extensions backwards and
   * pushes each one to the beginning of the array, conserving order, unless
   * there's a priority given, in which case it's inserted at a certain index.
   *
   * @param  {Object} extensions - an extension or array of extensions
   * @param  {Integer} priority - optional, how early the extensions are run
  ###

  register: (extensions, priority) ->
    if not Array.isArray(extensions) then extensions = [extensions]

    for ext in extensions.reverse()
      if typeof ext isnt 'function'
        @roots.bail(125, "Extension must return a function/class", ext)
      if priority? then @all.unshift(ext) else @all.splice(priority, 0, ext)

  ###*
   * Create a new instance of each extension, checking for any sort of errors
   * in the way the extension was configured.
   *
   * @return {Array} - array of instantiated extensions
  ###

  instantiate: ->
    extensions = @all.map (Ext) =>
      try ext = new Ext(@roots); catch err then @roots.bail(125, err, ext)
      check_extension_errors.call(@, ext)
      return ext

    extensions.hooks = hooks.bind(extensions)

    return extensions

  ###*
   * Ensures that all existant properties of an extension are functions.
   *
   * @param  {Function} ext - instance of an extension
  ###

  check_extension_errors = (ext) ->
    if not_function(ext.fs)
      @roots.bail(125, 'The fs property must be a function', ext)

    if not_function(ext.compile_hooks)
      @roots.bail(125, 'The compile_hooks property must be a function', ext)

    if not_function(ext.project_hooks)
      @roots.bail(125, 'The project_hooks property must be a function', ext)

    if not_function(ext.category_hooks)
      @roots.bail(125, 'The category_hooks property must be a function', ext)

  ###*
   * If exists and is not a function. Helper.
   *
   * @private
   *
   * @param  {???} prop - anything
   * @return {Boolean} whether it exists and is not a function or not
  ###

  not_function = (prop) -> prop and typeof prop isnt 'function'

  ###*
   * Returns a given extension's hook, if it exists. The nitty gritty:
   *
   * - Takes a hook name like 'compile_hooks.before'
   * - Splits it to a namespace and key at the period
   * - If an object is not returned, bail. This piece uses a really
   *   dirty hack to get access to the roots object out of scope.
   * - For each extension, if that namespace and key both exist
   *   and the extension is in its category, return the key
   *
   * @param  {String} name - hook name, separated with periods
   * @return {Function}      the hook function if exists, otherwise undefined
  ###

  hooks = (name, category) ->
    namespc = name.split('.')[0]
    key = name.split('.')[1]

    _.compact @map (ext) =>
      if not ext[namespc] then return
      called_namespace = ext[namespc]()

      if typeof called_namespace isnt 'object'
        @[@length-2].roots.bail(125, "#{namespc} should return an object", ext)

      if category?
        if called_namespace.category
          if called_namespace.category isnt category then return
        else
          if ext.category and ext.category isnt category then return

      called_namespace[key]

module.exports = Extensions
