minimatch = require 'minimatch'
_ = require 'underscore'
path = require 'path'
recursive_readdir = require 'recursive-readdir'
roots = require './index'
Asset = require './asset'

class Project
  ###*
   * Sets the root_dir and takes a config object and merges it into the
     Project config.
   * @constructor
   * @param {String} root_dir
   * @param {Object} config
  ###
  constructor: (root_dir, config={}) ->
    @root_dir = root_dir

    layout_files = (key for key of @layouts)

    #add ignore patterns from the config too!
    @ignore_patterns = _.union(
      @ignore_patterns,
      ["#{@public_dir}/**"],
      layout_files,
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
  root_dir: ''

  ###*
   * where the compiled files go
   * @type {String}
  ###
  public_dir: '/public'

  ###*
   * where the templates that compile into HTML go.
   * @type {String}
  ###
  views_dir: '/views'

  ###*
   * Where all images, scripts, styles, and other resources go.
   * @type {String}
  ###
  assets_dir: '/assets'

  ###*
   * Where the file holding the precompiled templates goes, relative to
     Project.public_dir
   * @type {String}
  ###
  precompiled_template_output: '/js/templates.js'

  ###*
   * the variables that get passed to all templates as locals
   * @type {Object}
  ###
  locals:
    livereload = '' # livereload won't render anything unless in watch mode

  ###*
   * [layouts description]
   * @type {Object}
  ###
  layouts: {}

  ###*
   * A list of minimatch patterns that match files which will not be compiled.
     Patterns are matched against the path relative to Project.root_dir.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignore_patterns: []

  ###*
   * A list of files that will not be compiled. This is partly generated from
     Project.ignore_patterns, and partly from manually appended files.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignore_files: ['/app.coffee']

  ###*
   * Using Project.ignore_patterns, determine what files in the project must
     be ignored and put them in Project.ignore_files. This function will need to be re-run whenever a file is added, but since it's deprecated, it's not worth optimizing
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  build_ignore_files: (cb) ->
    recursive_readdir(@root_dir, (err, files) =>
      console.error err if err
      for i in [0...files.length]
        files[i] = '/' + path.relative(@root_dir, files[i])

      @ignore_patterns.forEach (pattern) =>
        @ignore_files = _.union @ignore_files, minimatch.match(files, pattern, {})

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
   * @type {[type]}
  ###
  get_inital_files: ()

module.exports = Project
