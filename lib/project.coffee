path = require 'path'
EventEmitter = require('events').EventEmitter

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
   * Either 'build' or 'dev'
   * @type {String}
   * @public
  ###
  mode: 'build'

  ###*
   * Debug mode
   * @type {Boolean}
  ###
  debug: false

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
    public: './public'

    ###*
     * Where the file holding the precompiled templates goes, relative to
       Project.path('public')
     * @return {String} The relative path to the precompiledTemplateOutput
    ###
    precompiledTemplateOutput: -> "#{@['public']}/js/templates.js"

    ###*
     * Where the templates that compile into HTML go.
     * @type {String}
    ###
    views: './views'

    ###*
     * Where all images, scripts, styles, and other resources go.
     * @type {String}
    ###
    assets: './assets'

    ###*
     * Where plugins are stored
     * @type {String}
    ###
    plugins: './plugins'

  ###*
   * Get the full path to a directory
   * @uses Project.dirs [description]
  ###
  path: (dir) ->
    path.join(
      @rootDir,
      (if typeof @dirs[dir] is 'function' then @dirs[dir]() else @dirs[dir])
    )

  ###*
   * The variables that get passed to all templates as locals
   * @type {Object}
  ###
  locals:
    livereload: '' # livereload won't render anything unless in watch mode

  ###*
   * If livereload is enabled
   * @type {Boolean}
  ###
  livereloadEnabled: true

  ###*
   * [layouts description]
   * @type {Object}
  ###
  layouts: {}

module.exports = Project
