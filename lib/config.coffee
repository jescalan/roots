path   = require 'path'
fs     = require 'fs'
accord = require 'accord'
coffee = require 'coffee-script'
_      = require 'lodash'
os     = require('os')

###*
 * @class Config
 * @classdesc Manages configuration info and setup for roots
###

class Config
  ###*
   * This is an escaped version of the platform specific path seperator to be
   * used in regular expressions. It is defined as a (derived) constant,
   * because the path seperator does not change over the course of a run.
  ###
  
  PATH_SEPERATOR_REGEXP_STRING = path.sep.replace '\\', '\\\\'

  ###*
   * Creates a new instance of the roots config. This happens once, as soon as
   * you initialize the roots class. The constructor sets up a number of default
   * variables, explained below:
   *
   * - output: directory path appended to roots.root that results are written to
   * - dump_dirs: these directories dump their contents and appear transparent
   * - env: environment, usually development, staging, or production
   * - debug: when true, roots is more verbose in its output
   * - live_reload: when a compile finishes in watch more, reload the browser
   * - open_browser: when `roots watch` is run, open up the browser
   *
   * load_config loads in the app.coffee file, which can overwrite any of these
   * previous settings
   *
   * Then, we set up ignores if not provided by app.coffee, and add a couple
   * defaults that must always be ignored.
   *
   * Finally, we read the package.json file if present and grab all the adapters
   * needed to compile files in this project. More details on that later.
   *
   * @param  {Function} @roots - roots class instance
   *
   * @todo uniq filter ignores
  ###

  constructor: (@roots, opts) ->
    @output = 'public'
    @dump_dirs = ['views', 'assets']
    @env = opts.env ? 'development'
    @verbose = opts.verbose ? false
    @debug = false
    @live_reload = true
    @open_browser = !opts.no_open ? true

    load_config.call(@)

    @ignores ?= []
    @ignores = @ignores.concat [
      'package.json',
      'app*.coffee',
      "#{@output}/**/*",
      '.git*'
    ]

    @watcher_ignores ?= []
    @watcher_ignores = @watcher_ignores.concat [
      'package.json',
      'app.coffee',
      'node_modules/**/*',
      "#{@output}/**/*",
      '.git*'
    ]

    @compilers = get_compilers.call(@)

  ###*
   * This function is responsible for loading the app.coffee file into the
   * config.
   *
   * First, it checks the environment. If it's 'development', the default, roots
   * loads 'app.coffee', and if there is a custom environment, it tries to load
   * 'app.ENV_NAME.coffee'. It then makes sure the config file exists. If not,
   * it just returns, and if there was a custom environment logs out a warning.
   *
   * If it does exist, there are two ways app.coffee can be processed. First is
   * 'simple mode', entered if it doesn't export anything when the file is
   * required. In this mode, the config file is processed as a coffeescript
   * object.
   *
   * If the file does export anything, this means it's being used as a node
   * file, so it is required and processed as a node file.
   *
   * Each of the values that are exported are attached directly to the config
   * object, overwriting the defaults if this applies. Finally, extensions are
   * all registered with roots if they are provided.
  ###

  load_config = ->
    basename = if @env is 'development' then "app" else "app.#{@env}"
    config_path = path.join(@roots.root, basename)
    config_exists = fs.existsSync("#{config_path}.coffee")

    if not config_exists
      if @env isnt 'development'
        console.warn "\nEnvironment config file not found. Make sure
        'app.#{@env}.coffee' is present at the root of your project.\n".yellow
      return

    conf = require(config_path)
    if Object.keys(conf).length < 1
      conf = eval coffee.compile(
        fs.readFileSync("#{config_path}.coffee", 'utf8'), { bare: true }
      )

    @[k] = v for k, v of conf

    @roots.extensions.register(@extensions) if @extensions

  ###*
   * Produces the full path to the output folder
   * @return {String} - path to output folder
  ###

  output_path: ->
    path.join(@roots.root, @output)

  ###*
   * Given a vinyl-wrapped file and optional extension, this function produces
   * the path to the file's destination. To do so, it goes through these steps:
   *
   * - Take the relative path and split it by /
   * - If it's in a 'dumped' directory, remove that directory
   * - URI encode any strange characters
   * - Add the full path to the output folder to the beginning
   * - Join it back together with /
   * - If an extension override was provided, replace the extension
   *
   * @param  {File} f - vinyl instance
   * @param  {String} ext - file extension, no dot
   * @return {String} path to where the file should be written
  ###

  out: (f, ext) ->
    res = f.relative.split(path.sep)
    if _.includes(@dump_dirs, res[0]) then res.shift()
    res.unshift(@output_path())
    res = res.join(path.sep)
    if ext
      res = res.replace(///\.[^#{PATH_SEPERATOR_REGEXP_STRING}]*$///, ".#{ext}")
    res

  ###*
   * Grabs all adapters necessary to compile files in this project.
   * Scans the package.json file's dependencies for packages that have
   * registered accord adapters and loads those. Alerts if dependencies
   * have not been installed.
   *
   * @private
   *
   * @return {Array} - array of accord adapters
  ###

  get_compilers = ->
    res = {}
    pkg_json_path = path.join(@roots.root, 'package.json')
    if not fs.existsSync(pkg_json_path) then return res

    pkg = require(pkg_json_path)
    for dep in _.keys(pkg.dependencies).concat(_.keys(pkg.devDependencies))
      if accord.supports(dep)
        try
          local_compiler = path.join(@roots.root, 'node_modules', dep)
        catch err
          throw new Error("'#{dep}' not found. install it with 'npm install'")

        res[dep] = accord.load(dep, local_compiler)

    return res

module.exports = Config
