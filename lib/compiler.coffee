fs     = require 'graceful-fs'
path   = require 'path'
_      = require 'lodash'
W      = require 'when'
nodefn = require 'when/node/function'
pipeline = require 'when/pipeline'
sequence = require 'when/sequence'

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
    @file_options = { filename: @file.path }

  ###*
   * Initialize the actual compilation. This method is a higher level wrapper for
   * a promise chain, summarized as such:
   *
   * - reads the file's content, set on the instance
   * - run the before hooks for each extensions before_file hook
   * - take each pass over the file, and compile, set compiled content on instance
   * - emit a compile event once finished passing the file vinyl wrapper
   * - run the extensions' after hooks
   * - write the file
   * 
   * @return {Promise} promise for a compiled and written file
  ###

  run: ->
    read_file(@file)
      .then((o) => @content = o)
      .then(=> sequence(@extensions.hooks('compile_hooks.before_file'), @))
      .then(each_pass.bind(@))
      .tap((o) => @content = o)
      .tap(=> @roots.emit('compile', @file))
      .then(=> sequence(@extensions.hooks('compile_hooks.after_file'), @))
      .then(write_file.bind(@))
  
  ###*
   * Async utf8 file read from a vinyl file wrapped in a promise.
   *
   * @private
   * 
   * @param  {f} f - vinyl-wrapped file
   * @return {Promise} a promise for the file's contents
  ###

  read_file = (f) ->
    nodefn.call(fs.readFile, f.path, { encoding: 'utf8' })

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
    sequence(@extensions.hooks('compile_hooks.write'), @)
      .then(process_write_hook_results.bind(@))
      .then(W.all)

  ###*
   * Given an array of results from each extension's write_hook, if
   * present, figure out how to handle the actual writes, then delegate
   * them to one or multiple `write_task`s.
   *
   * - If there are no write hooks, file is written as usual
   * - If a write hook returns false, file is not written regardless of anything else
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
  ###

  process_write_hook_results = (results) ->
    if results.length < 1 then return [write_task.call(@)]
    if _.contains(results, false) then return []

    write_tasks = []
    normal_write_pushed = false

    for res in results
      if res == true and not normal_write_pushed
        write_tasks.push(write_task.call(@))
        normal_write_pushed = true
      else if typeof res == 'object'
        write_tasks.push(write_task.call(@, res))
      else if Array.isArray(res)
        write_tasks.concat(res.map((i) => write_task.call(@, i)))
      else
        @roots.bail(126, res)

    return W.resolve(write_tasks)

  ###*
   * A helper function for write_file, this is a single write task. It accepts
   * an object with a path and content property. If not provided, it uses a
   * default. It then writes the content to the path asynchronously.
   * 
   * @param  {Object} obj - object with `path` and `content` properties
   * @return {Promise} a promise for the written file
  ###

  write_task = (obj) ->
    obj ?= {
      path: @roots.config.out(@file.path, _.last(@adapters).output)
      content: @content
    }

    if !obj.path? or !obj.content? then @roots.bail(126, o)
    nodefn.call(fs.writeFile, obj.path, obj.content)

  ###*
   * Read the file's extension and grab any and all adapters that match. If there
   * isn't a matching adapter, returns an adapter stub that is used to just copy
   * the file.
   * 
   * @return {Array} an array of adapter objects, in order
  ###

  get_adapters = ->
    extensions = path.basename(@file.path).split('.').slice(1)
    adapters = []
    
    for ext in _.clone(extensions).reverse()
      compiler = _.find(@roots.config.compilers, (c) -> _.contains(c.extensions, ext))
      adapters.push(if compiler then compiler else { output: ext })

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
    pipeline(@adapters.map((a,i) => pass.run.bind(pass,a,i+1)), @content)

###*
 * @class CompilePass
 * @classdesc Handles one compilation pass on a file's content.
###

class CompilePass

  ###*
   * Creates a new instance, holding on to a reference to the CompileFile instance.
   * @param  {Function} file - instance of CompileFile
  ###

  constructor: (@file) ->

  ###*
   * Initialize the compile. Takes an adapter, the index (number of the pass), and
   * content. It takes a couple steps:
   *
   * - First, get the options to be passed in with the adapter, described below
   * - Then execute any before pass hooks
   * - Then actually compile, or if no compilation needed just pass the content on
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

  run: (@adapter, @index, @content) ->
    @opts = configure_options.call(@)

    sequence(@file.extensions.hooks('compile_hooks.before_pass'), @)
      .then(compile_or_pass.bind(@))
      .then((o) => @content = o)
      .then(=> sequence(@file.extensions.hooks('compile_hooks.after_pass'), @))
      .then(=> @content)

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
    global_options  = @file.roots.config.locals || {}
    adapter_options = @file.roots.config[@adapter.name] || {}
    file_options    = @file.file_options
    compile_options = @file.compile_options

    _.extend(global_options, adapter_options, file_options, compile_options)

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
    if not @adapter.name then return @content
    @adapter.render(@content, @opts)
