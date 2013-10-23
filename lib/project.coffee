path = require 'path'
EventEmitter = require('events').EventEmitter

###*
 * @class Manages the configuration of the project. This depricates `global.options`.
###
class Project extends EventEmitter
  ###*
   * Sets the rootDir and takes a config object and merges it into the
     Project config.
   * @constructor
   * @param {String} rootDir
   * @param {Object} config
  ###
  constructor: (rootDir, config={}) ->
    @rootDir = path.normalize(rootDir)
    return

  ###*
   * A getter for configuration variables. It gets used a lot, so it's best
     with a shortened name. This abstraction is used to automatically call
     functions that have defined as configuration variables. Thus, we are able
     to have "dynamic configuration variables" that are really just 0-param
     functions that make a value based on other configuration vars.
   * @param {String} keystring The name of the config variable to get. Dot
     notation can be used to get nested keys.
   * @return {Object} Whatever the configuration variable is, or if that was a
     function: what it returned.
  ###
  conf: (keystring) ->
    val = @
    for key in keystring.split '.'
      thisArg = val
      val = val[key]
    if typeof val is 'function' then val = val.call(thisArg)
    return val

  ###*
   * Either 'build' or 'dev'
   * @type {String}
   * @public
  ###
  mode: 'build'

  ###*
   * Should assets be compressed?
   * @return {Boolean}
  ###
  compress: -> @mode is 'build'

  ###*
   * Debug mode
   * @type {Boolean}
  ###
  debug: false

  ###*
   * The variables that get passed to all templates as locals
   * @type {Object}
  ###
  locals: {}

  ###*
   * If livereload is enabled
   * @type {Boolean}
  ###
  livereloadEnabled: true

  ###*
   * If watch should open browser
   * @type {Boolean}
  ###
  open: true

  ###*
   * [layouts description]
   * @type {Object}
  ###
  layouts: {}

  ###*
   * The path to the root of the project.
   * @type {String}
  ###
  rootDir: ''

  ###*
   * A set of important directories, as paths (or functions that make paths)
     relative to Project.rootDir
   * @type {Object}
   * @private
  ###
  dirs:
    ###*
     * Where the compiled files go.
     * @type {String}
    ###
    public: 'public'

    ###*
     * Where the file holding the precompiled templates goes.
     * @return {String} The relative path to the precompiledTemplateOutput
    ###
    precompiledTemplateOutput: -> "#{@['public']}/js/templates.js"

    ###*
     * Where the templates that compile into HTML go.
     * @type {String}
    ###
    views: 'views'

    ###*
     * Where all images, scripts, styles, and other resources go.
     * @type {String}
    ###
    assets: 'assets'

    ###*
     * Where the components installed via bower go.
     * @return {String} The relative path to the precompiledTemplateOutput
    ###
    components: -> "#{@['assets']}/components"

    ###*
     * Where plugins are stored
     * @type {String}
    ###
    plugins: 'plugins'

  ###*
   * Get the full path to a directory
   * @uses Project.dirs [description]
  ###
  path: (dir) ->
    path.join(
      @rootDir,
      @conf "dirs.#{dir}"
    )

module.exports = Project
