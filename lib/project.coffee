minimatch = require 'minimatch'
_ = require 'underscore'
path = require 'path'
fs = require 'fs'

class Project
  ###*
   * all of the files in the project
   * @type {Array}
  ###
  assets: []

  ###*
   * The path to the root of the project.
   * @type {String}
  ###
  root_dir: process.cwd()

  ###*
   * where the compiled files go
   * @type {String}
  ###
  output_folder: 'public'

  ###*
   * the location of each of the "special" folders
   * @type {Object}
  ###
  folder_config:
    views: 'views'
    assets: 'assets'

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
     Patterns are matched aginst the path relative to Project.root_dir.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignore_patterns: ['/app.coffee']

  ###*
   * A list of files that will not be compiled. This is partly generated from
     Project.ignore_patterns, and partly from manually appended files.
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignore_files: ['']

  ###*
   * Using Project.ignore_patterns, determine what files in the project must
     be ignored and put them in Project.ignore_files
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  build_ignore_files: ->
    files = fs.readdirSync(@root_dir)
    for file in files
      file = path.relative(@root_dir, file)

    @ignore_patterns.forEach (pattern) ->
      @ignore_files = _.union @ignore_files, minimatch.match(files, pattern)
    return

module.exports = Project
