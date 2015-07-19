fs       = require 'fs'
W        = require 'when'
nodefn   = require 'when/node'
guard    = require 'when/guard'
keys     = require 'when/keys'
sequence = require 'when/sequence'
mkdirp   = require 'mkdirp'
_        = require 'lodash'

FSParser = require '../fs_parser'
Compiler = require '../compiler'

###*
 * @class Compile
 * @classdesc Compiles a project
###

class Compile

  ###*
   * Creates a new instance of the compile class.
   *
   * - makes a new fs parser instance
   * - makes a new compiler instance
   * - makes a new instance of each extension, with error detection.
   *   this must happen every compile pass to clear lingering context
   *
   * @param  {Function} roots - instance of the base roots class
  ###

  constructor: (@roots) ->
    @extensions = @roots.extensions.instantiate()
    @fs_parser = new FSParser(@roots, @extensions)
    @compiler = new Compiler(@roots, @extensions)

  ###*
   * Compiles the project. This process includes the following steps:
   *
   * - execute user before hooks if present
   * - parse the project, sort files into categories
   * - create the folder structure
   * - compile and write each of the files
   * - execute user after hooks if present
   * - removes any empty folders that exist after compile
   * - emit finished events
  ###

  exec: (opts) ->
    __track('api', { name: 'compile' })

    if opts
      @roots.file_changed = opts.fileChanged

    @roots.emit('start')

    before_hook.call(@)
      .then(setup_extensions.bind(@))
      .then(@fs_parser.parse.bind(@fs_parser))
      .with(@)
      .tap(create_folders)
      .then(process_files)
      .then(after_ext_hook)
      .then(after_hook)
      .then(purge_empty_folders)
      .then @roots.emit.bind(@roots, 'done'), (err) ->
        @roots.emit('error', err)
        W.reject(err)

  ###*
   * Calls any user-provided before hooks with the roots context.
   *
   * @private
  ###

  before_hook = ->
    hook_method.call(@, @roots.config.before)

  ###*
   * Calls any user-provided after hooks with the roots context.
   *
   * @private
  ###

  after_hook = (ast) ->
    hook_method.call(@, @roots.config.after)

  ###*
   * Calls any extension-provided after hooks with the roots context.
   *
   * @private
  ###

  after_ext_hook = ->
    sequence(@extensions.hooks('project_hooks.after'), @)

  ###*
   * Checks to ensure the requested hook(s) is/are present, then calls them,
   * whether there was an array of hooks provided or just a single hook.
   *
   * @private
   *
   * @param  {Array|Function} hook - a function or array of functions
   * @return {Promise} promise for resolved hooks
  ###

  hook_method = (hook) ->
    if not hook then return W.resolve()

    if Array.isArray(hook)
      hooks = hook.map((h) => nodefn.lift(_.partial(h, @roots).call(@roots)))
    else if typeof hook is 'function'
      hooks = [nodefn.lift(_.partial(hook, @roots).call(@roots))]
    else
      return W.reject('before hook should be a function or array')

    W.all(hooks)

  ###*
   * If present, runs an async-compatible `setup` function in each extension,
   * ensuring that any asynchrnonous setup the extension needs is completed.
   *
   * @return {Promise} a promise that the extension setup is finished
  ###

  setup_extensions = ->
    req_setup = @extensions.filter((ext) -> !!ext.setup)
    W.map(req_setup, ((ext) -> ext.setup()))

  ###*
   * Creates the nested folder structure for a project. First, creates an array
   * of just the output paths, then creates the base public folder, then
   * sequentially walks through the folders and creates them all.
   *
   * @param  {Object} ast - roots ast
  ###

  create_folders = (ast) ->
    output_paths = ast.dirs.map((d) => @roots.config.out(d))
    @__dirs = output_paths

    nodefn.call(mkdirp, @roots.config.output_path())
      .then ->
        W.map(output_paths, guard(guard.n(1), ((p) -> nodefn.call(mkdirp, p) )))

  ###*
   * Files are processed by category, and each category can be processed in
   * One of two ways: parallel or ordered. Parallel processed categories will
   * crunch through their files as quickly as possible, starting immediately.
   * Ordered categories will parallel compile all the files in the category, but
   * wait until one category is finished before moving to the next one.
   *
   * An example use for each of these is client templates and dynamic content.
   * With client templates, they do not depend on any other compile process so
   * they are a great fit for parallel. For dynamic content, the front matter
   * must be parsed then available in normal templates, which means all dynamic
   * content must be finished parsing before normal content starts. For this
   * reason, dynamic content has to be ordered so it is placed before the normal
   * compiles.
   *
   * So what this function does is first distinguishes ordered or parallel for
   * each extension, then pushes a compile task for that extension onto the
   * appropriate stack. The compile task just grabs the files from the category
   * and runs them each through the compiler's `compile` method. Then when they
   * are finished, it runs the after category hook.
   *
   * Once the ordered and parallel stacks are full of tasks, they are run.
   * Ordered gets sequenced so they run in order, and parallel runs (surprise)
   * in parallel.
   *
   * @param  {Object} ast - roots ast
  ###

  process_files = (ast) ->
    ordered = []
    parallel = []

    compile_task = (cat) =>
      W.map(ast[cat] ? [], @compiler.compile.bind(@compiler, cat))
      .then(=> sequence(@extensions.hooks('category_hooks.after', cat), @, cat))

    for ext in @extensions
      extfs = if ext.fs then ext.fs() else {}
      category = if extfs.category then extfs.category else ext.category

      if typeof extfs isnt 'object'
        @roots.bail(125, 'fs must return an object', ext)

      # if extfs has keys, but no category, bail
      if Object.keys(extfs).length > 0 and not extfs.category and not category
        @roots.bail(125, 'fs hooks defined with no category', ext)

      if extfs.ordered
        ordered.push(((c) => compile_task.bind(@, c))(category))
      else
        parallel.push(compile_task.call(@, category))


    keys.all
      ordered: sequence(ordered)
      parallel: W.all(parallel)

  ###*
   * Sometimes extensions prevent file writes and leave behind empty folders.
   * The client templates extension is a good example. No matter how it happens,
   * there should not be any empty folders in the output, so this method gets
   * rid of them if they exist.
   *
   * The way this is done is *very* hacky, but it is the speediest way. It
   * tries to delete every folder, and if it succeeds, it means the folder was
   * empty, as trying to remove a directory with contents throws an error (which
   * we ignore using an empty callback).
   *
   * @private
  ###

  purge_empty_folders = ->
    @__dirs.map (d) -> fs.rmdir(d, ->)

module.exports = Compile
