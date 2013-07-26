minimatch = require 'minimatch'
_ = require 'underscore'
path = require 'path'
recursiveReaddir = require 'recursive-readdir'
EventEmitter = require('events').EventEmitter
roots = require './index'
Asset = require './asset'

class Project extends EventEmitter
  ###*
   * Sets the rootDir and takes a config object and merges it into the
     Project config.
   * @constructor
   * @param {String} rootDir
   * @param {Object} config
  ###
  constructor: (rootDir, config={}) ->
    @rootDir = rootDir

    layoutFiles = (key for key of @layouts)

    #add ignore patterns from the config too!
    @ignorePatterns = _.union(
      @ignorePatterns,
      ["#{@path('public')}/**"],
      layoutFiles,
    )
    return

  ###*
   * either 'build' or 'dev'
   * @type {String}
   * @public
  ###
  mode: 'build'

  ###*
   * debug mode
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
     * where the compiled files go.
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
     * where the templates that compile into HTML go.
     * @type {String}
    ###
    views: './views'

    ###*
     * Where all images, scripts, styles, and other resources go.
     * @type {String}
    ###
    assets: './assets'

    ###*
     * where plugins are stored
     * @type {String}
    ###
    plugins: './plugins'

  ###*
   * get the full path to a directory
   * @uses Project.dirs [description]
  ###
  path: (dir) ->
    path.join(
      @rootDir,
      (if typeof @dirs[dir] is 'function' then @dirs[dir]() else @dirs[dir])
    )


  ###*
   * the variables that get passed to all templates as locals
   * @type {Object}
  ###
  locals:
    livereload: '' # livereload won't render anything unless in watch mode

  ###*
   * if livereload is enabled
   * @type {Boolean}
  ###
  livereloadEnabled: true

  ###*
   * [layouts description]
   * @type {Object}
  ###
  layouts: {}

  ###*
   * A list of minimatch patterns that match files which will not be compiled.
     Patterns are matched against the path relative to Project.rootDir.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignorePatterns: []

  ###*
   * A list of files that will not be compiled. This is partly generated from
     Project.ignorePatterns, and partly from manually appended files.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignoreFiles: ['/app.coffee']

  ###*
   * Using Project.ignorePatterns, determine what files in the project must
     be ignored and put them in Project.ignoreFiles. This function will need to be re-run whenever a file is added, but since it's deprecated, it's not worth optimizing
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  buildIgnoreFiles: (cb) ->
    recursiveReaddir(@rootDir, (err, files) =>
      if err then roots.print.error err
      for i in [0...files.length]
        files[i] = '/' + path.relative(@rootDir, files[i])

      @ignorePatterns.forEach (pattern) =>
        @ignoreFiles = _.union @ignoreFiles, minimatch.match(files, pattern, {})

      cb()
    )

  ###*
   * all of the files in the project that we're watching
   * @type {Array}
  ###
  assets: []

  ###*
   * Right now, this function just loads all the files in the project that
     aren't being ignored. But when asset graph is working, it will just load
     the layout files. And then all other files will be detected from there.
  ###
  getInitalFiles: (cb) =>
    recursiveReaddir(@rootDir, (err, files) =>
      if err then roots.print.error err
      for file in files
        @addAsset file

      cb()
    )

  ###*
   * add an Asset to the project
   * @param {String} path The full path to the Asset.
  ###
  addAsset: (path) ->
    if path in ignoreFiles
      throw "Asset (#{path}) is supposed to be ignored."
    else
      @assets.push new Asset(path)

module.exports = Project
