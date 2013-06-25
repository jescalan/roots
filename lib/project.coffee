minimatch = require 'minimatch'
_ = require 'underscore'

class Project
  ###*
   * all of the files in the project
   * @type {Array}
  ###
  assets: []

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
   * @type {Array}
   * @deprecated Once Asset Graph is fully functional, this will not be needed
     and will be removed
  ###
  ignore_patterns: ['']

  ###*
   * A list of files that will not be compiled. This is partly generated from
     Project.ignore_patterns, and partly from manually appended files.
   * @type {Array}
  ###
  ignore_files: ['']

  ###*
   * Using Project.ignore_patterns, determine what files in the project must
     be ignored and put them in Project.ignore_files
  ###
  build_ignore_files: ->
    files = fs.readdirSync(template_dir)

    @ignore_patterns.forEach (pattern) ->
      @ignore_files = _.union @ignore_files, minimatch.match(files, pattern)
    return
