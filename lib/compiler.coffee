fs       = require 'graceful-fs'
path     = require 'path'
_        = require 'lodash'
W        = require 'when'
nodefn   = require 'when/node'
pipeline = require 'when/pipeline'
sequence = require 'when/sequence'
File     = require 'vinyl'
mkdirp   = require 'mkdirp'

###*
 * @class Compiler
 * @classdesc Responsible for compiling files, multipass included
###

class Compiler

  ###*
   * Creates a new compiler instance, which holds on to the roots instance
   * as well as an array of initialized extensions, and creates an empty
   * options object, which is re-created per-compile.
   *
   * @param  {Function} @roots - Roots class instance
   * @param  {Function} @extensions - array of initialzed extensions
  ###

  constructor: (@roots, @extensions) ->
    @options = {}

  ###*
   * Compile a single file asynchronously.
   *
   * @param  {String} category - category the file is being compiled in
   * @param  {File} file - vinyl-wrapped file
   * @return {Promise} promise for the fully compiled file
  ###

  compile: (category, file) ->
    cf = new CompileFile(@roots, @extensions, @options, category, file)
    cf.run()

module.exports = Compiler

###*
 * @class CompileFile
 * @classdesc Compiles a single file, separate class to allow for working
 *            easily with a scope that doesn't interfere with anything else.
 * @private
###

class CompileFile

  ###*
   * Creates a new instances of the CompileFile class. Grabs the adapter(s)
   * needed to compile the file, creates the per-file options object and adds
   * filename to it.
   *
   * @param  {Function} roots           Roots class instance
   * @param  {Array}    extensions      Array of initialzed extensions
   * @param  {Object}   compile_options Per-compile options object
   * @param  {String}   category        Category of file being compiled
   * @param  {File}     file            Vinyl-wrapped file
  ###

  constructor: (@roots, @extensions, @compile_options, @category, @file) ->
    @adapters = get_adapters.call(@)
    @is_compiled = !!_(@adapters).map('name').compact().value().length
    @out_ext = _.last(@adapters).output
    @file_options = {filename: @file.path, _path: url_path.call(@)}

  ###*
   * Initialize the actual compilation. This method is a higher level wrapper
   * for a promise chain, summarized as such:
   *
   * - reads the file's content, set on the instance
   * - run the before hooks for each extensions before_file hook
   * - take each pass over the file, compile, set compiled content on instance
   * - emit a compile event once finished passing the file vinyl wrapper
   * - run the extensions' after hooks
   * - write the file
   *
   * @return {Promise} promise for a compiled and written file
  ###

  run: ->
    hooks = (cat) => @extensions.hooks(cat, @category)

    read_file.call(@, @file)
      .with(@)
      .then((o) => @content = o)
      .then(=> sequence(hooks('compile_hooks.before_file'), @))
      .then(each_pass)
      .tap (o) =>
        @content = o.result
        @sourcemap = o.sourcemap
      .tap(=> @roots.emit('compile', @file))
      .then(=> sequence(hooks('compile_hooks.after_file'), @))
      .then(write_file)

  ###*
   * Async utf8 file read from a vinyl file wrapped in a promise.
   *
   * @private
   *
   * @param  {f} f - vinyl-wrapped file
   * @return {Promise} a promise for the file's contents
  ###

  read_file = (f) ->
    options = null

    # if the file is compiled, read as utf8, if not read as buffer
    opts = if @is_compiled then encoding: 'utf8' else null
    nodefn.call(fs.readFile, f.path, opts)

  ###*
   * Writes a file from the content property on the instance. Can be modified
   * by a write_hook from an extension.
   *
   * - Run through extension write hooks
   * - Process the results of each and create write tasks (see below)
   * - Move on once all write tasks have been completed
   *
   * @private
   *
   * @return {Promise} promise for written file(s)
   *
   * @todo adjust config.out to work better with vinyl
  ###

  write_file = ->
    sequence(@extensions.hooks('compile_hooks.write', @category), @)
      .then(process_write_hook_results.bind(@))
      .then(write_sourcemaps_if_present.bind(@))
      .then(W.all)

  ###*
   * Given an array of results from each extension's write_hook, if
   * present, figure out how to handle the actual writes, then delegate
   * them to one or multiple `write_task`s.
   *
   * - If there are no write hooks, file is written as usual
   * - If a write hook returns false, file is not written ever
   * - If a write hook returns true, file is written as usual (once at max)
   * - If a write hook returns an object or array of objects with
   *   path and content props, the file(s) is/are written to the
   *   provided path(s) with the provided content(s)
   * - If a write hook returns anything else, roots bails
   *
   * We then return an array of promises for all write tasks.
   *
   * @param  {Array} results - results from all write hooks
   * @return {Array} an array of promises for written files
   *
   * @todo if custom path is given, it always also writes standard
  ###

  process_write_hook_results = (results) ->
    if results.length < 1 then return [write_task.call(@)]
    if _.includes(results, false) then return []

    write_tasks = []
    normal_write_pushed = false

    for res in results
      if res is true
        if not normal_write_pushed then write_tasks.push(write_task.call(@))
        normal_write_pushed = true
      else if typeof res is 'object' and not Array.isArray(res)
        write_tasks.push(write_task.call(@, res))
      else if Array.isArray(res)
        write_tasks.concat(res.map((i) => write_task.call(@, i)))
      else
        @roots.bail(126, 'invalid return from write_hook', res)

    return W.resolve(write_tasks)

  write_sourcemaps_if_present = (tasks) ->
    if not @sourcemap then return tasks

    f = new File
      base: @roots.root
      path: @file.path + '.map'

    tasks.push write_task.call @,
      path: f
      content: JSON.stringify(@sourcemap)
      sourcemap: true

    return W.resolve(tasks)

  ###*
   * Single task to write a file. Accepts an optional object with the following
   * keys:
   *
   * - path: relative (to root) or absolute path to write to
   * - content: content to write
   * - extension: extension to write the file with
   *
   * If an object is passed, each of these keys is optional, and if not provided
   * will be filled in with default values. The path then is wrapped with vinyl,
   * passed through the roots output path generator, and the file is written.
   * The extension property is only set if there wasn't already an extension
   * override and there was a compile, otherwise any extensions are preserved as
   * is.
   *
   * If there is a sourcemap for one of the files being written, two things need
   * to happen. First, the sourcemap needs to be written with a .map extension.
   * Second, the output file needs to get a source mapping url comment so that
   * it knows where the sourcemap is. Both of these things happen as well in
   * this method.
   *
   * @param  {Object} obj - object with `path` and `content` properties
   * @return {Promise} a promise for the written file
  ###

  write_task = (obj = {}) ->
    obj = _.defaults obj,
      path: @file
      content: @content

    if not obj.extension? and @is_compiled
      obj.extension = @out_ext

    if obj.sourcemap?
      obj.extension += '.map'

    if not (obj.path instanceof File)
      obj.path = new File(base: @roots.root, path: obj.path)

    obj.path = @roots.config.out(obj.path, obj.extension)

    if @sourcemap and not obj.sourcemap?
      if @out_ext is 'css'
        obj.content = "#{obj.content}\n
        /*# sourceMappingURL=#{path.basename(obj.path)}.map */"
      if @out_ext is 'js'
        obj.content = "#{obj.content}\n
        //# sourceMappingURL=#{path.basename(obj.path)}.map"

    nodefn.call(mkdirp, path.dirname(obj.path))
      .then(-> nodefn.call(fs.writeFile, obj.path, obj.content))

  ###*
   * Read the file's extension and grab any and all adapters that match. If
   * there isn't a matching adapter, returns an adapter stub that is used to
   * just copy the file.
   *
   * If no adapters are found, it's a file with no extension, so it gets a stub
   * adapter with no extension.
   *
   * @return {Array} an array of adapter objects, in order
  ###

  get_adapters = ->
    extensions = path.basename(@file.path).split('.').slice(1)
    adapters = []

    for ext in _.clone(extensions).reverse()
      compiler = _.find @roots.config.compilers, (c) ->
        _.includes(c.extensions, ext)

      adapters.push(if compiler then compiler else { output: ext })

    if !adapters.length then adapters.push(output: '')

    return adapters

  ###*
   * Initializes the actual compilation of the file. Since each pass is it's
   * own task, it gets its own context. This method runs pipeline, which runs
   * through an array and passes one's output to the next. Before doing this,
   * it binds an adapter and an index to each compile pass.
   *
   * @return {Promise} a promise for the compiled content of the file
  ###

  each_pass = ->
    pass = new CompilePass(@)
    pipeline(@adapters.map((a,i) -> pass.run.bind(pass, a, i + 1)),
      { result: @content })

  ###*
   * Returns the absolute path to the file as requested through the browser,
   * excluding the hostname, port, etc.
   *
   * @return {String} the absolute URL as requested through the browser
   *
  ###

  url_path = ->
    f = new File(base: @roots.root, path: @file.path)
    out_path = @roots.config.out(f, @out_ext)
    p = path.relative(path.join(@roots.root, @roots.config.output), out_path)
    return "/#{p.replace(path.sep, '/')}"

###*
 * @class CompilePass
 * @classdesc Handles one compilation pass on a file's content.
###

class CompilePass

  ###*
   * Creates a new instance, holding on to a ref to the CompileFile instance.
   * @param  {Function} file - instance of CompileFile
  ###

  constructor: (@file) ->

  ###*
   * Initialize the compile. Takes an adapter, the index (number of the pass),
   * and content. It takes a couple steps:
   *
   * - First, get the options to be passed in with the adapter, described below
   * - Then execute any before pass hooks
   * - Then actually compile, or if not needed just pass the content on
   * - Then set the content on the context
   * - Then execute any after_pass hooks
   * - Finally, return the content
   *
   * @param  {Object} @adapter - accord adapter to compile with
   * @param  {Integer} @index - # of the compile pass
   * @param  {String} @content - the content to be compiled
   * @return {Promise} a promise for the compiled content
   *
   * @todo is there a way to yield(@content)?
  ###

  run: (@adapter, @index, @input) ->
    hooks = (cat) => @file.extensions.hooks(cat, @file.category)

    @content = @input.result

    sequence(hooks('compile_hooks.before_pass'), @)
      .with(@)
      .tap(=> @opts = configure_options.call(@))
      .then(compile_or_pass)
      .then (o) =>
        @content = o.result
        res = { result: @content }
        if o.sourcemap
          @sourcemap = o.sourcemap
          res.sourcemap = @sourcemap
        return res
      .tap(=> sequence(hooks('compile_hooks.after_pass'), @))

  ###*
   * This function is responsible for getting all the options together for the
   * compilation. Tried to be clear as possible here with the code, as you can
   * see there are 4 different options objects that are merged together to make
   * the package of options that are passed in for each file.
   *
   * - global options: set in app.coffee, these are options that are present in
   *   every file, no matter what
   * - adapter options: also set in app.coffee, these options are specific to an
   *   adapter. For example, setting `pretty` to `true` for jade only
   * - file options: options that persist only for a single file, for all passes
   * - compile options: options that persist through each time the project
   *   compiles, but are cleared between one compile and the next
   *
   * @private
   *
   * @return {Object} - all options merged into a single object
  ###

  configure_options = ->
    global_options  = @file.roots.config.locals ? {}
    adapter_options = @file.roots.config[@adapter.name] ? {}
    file_options    = @file.file_options
    compile_options = @file.compile_options

    _.extend({}, global_options, adapter_options, file_options, compile_options)

  ###*
   * As small of a function as this is, it's the one that actually is doing
   * the work to compile the files. First it checks if the adapter has a name,
   * which is a requirement of all accord adapters. If not, it's likely a stub
   * adapter used to copy the file, and it returns the content.
   *
   * If there is a name this means we have a legit adapter, and it runs the
   * compile and returns a promise for the content.
   *
   * @return {Promise|String} a string or promise for a string of content
   *
   * @todo maybe use instance rather than name to classify?
  ###

  compile_or_pass = ->
    if not @adapter.name then return @input
    if not @content.length then return @input
    @adapter.render(@content, @opts)
