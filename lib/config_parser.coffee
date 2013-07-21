fs = require 'fs'
path = require 'path'
shell = require 'shelljs'
adapters = require './adapters'
colors = require 'colors'
coffee = require 'coffee-script'
roots = require '../index'

###*
 * Config Parser - Parses the app.coffee file in a roots project, adds and
   configures any additional options, and puts all config options inside
   `global.options`
 * @param {[type]} args [description]
 * @param {Function} cb [description]
 * @return {[type]} [description]
###
module.exports = (args, cb) ->
  # pull the app config file
  opts = undefined
  config_path = path.join(roots.project.rootDir + '/app.coffee')
  contents = (if fs.existsSync(config_path) then fs.readFileSync(config_path, 'utf8') else '{}')

  # fallback for old roots versions
  if contents.match(/exports\./)
    opts = global.options = require(config_path)
  else
    opts = global.options = eval(coffee.compile(contents,
      bare: true
    ))

  
  #opts.locals = opts.locals or {}
  #opts.locals.livereload = ''

  # add order function to locals
  opts.locals.sort = (ary, opts) ->
    opts = opts or {}
    opts.by = opts.by or 'order'
    return ary.sort(opts.fn)  if opts.fn
    if opts.by is 'date'
      return ary.sort((a, b) ->
        if new Date(a[opts.by]) > new Date(b[opts.by])
          -1
        else
          1
      )
    if opts.order is 'asc'
      ary.sort (a, b) ->
        if a[opts.by] > b[opts.by] then -1 else 1
    else
      ary.sort (a, b) ->
        if a[opts.by] < b[opts.by] then -1 else 1

  # figure out which files need to be compiled
  extensions = opts.compiled_extensions = []

  for key of adapters
    extensions.push adapters[key].settings.file_type

  # make sure all layout files are ignored
  #opts.ignoreFiles = opts.ignoreFiles or []
  #opts.layouts = opts.layouts or {}

  #for key of opts.layouts
  #  opts.ignoreFiles.push opts.layouts[key]

  # add plugins, and public folders to the folder ignores
  opts.ignore_folders = opts.ignore_folders or []
  opts.ignore_folders = opts.ignore_folders.concat([opts.output_folder, 'plugins'])

  # ignore js templates folder
  # this is currently not working because of an issue with
  # readdirp: https://github.com/thlorenz/readdirp/issues/4
  if opts.templates then opts.ignore_folders = opts.ignore_folders.concat([opts.templates])

  # configure the base watcher ignores
  opts.watcher_ignore_folders = opts.watcher_ignore_folders or []
  opts.watcher_ignoreFiles = opts.watcher_ignoreFiles or []
  
  opts.watcher_ignore_folders = opts.watcher_ignore_folders.concat(['components', 'plugins', '.git', opts.output_folder])
  opts.watcher_ignoreFiles = opts.watcher_ignoreFiles.concat(['.DS_Store'])

  format_ignores = (ary) ->
    ary.map (pat) ->
      '!' + pat.toString().replace(/\//g, '')

  # format the file/folder ignore patterns
  #opts.ignoreFiles = format_ignores(opts.ignoreFiles)
  #opts.ignore_folders = format_ignores(opts.ignore_folders)
  #opts.watcher_ignore_folders = format_ignores(opts.watcher_ignore_folders)
  #opts.watcher_ignoreFiles = format_ignores(opts.watcher_ignoreFiles)

  #opts.debug = status: (opts.debug or args.debug)

  #opts.debug.log = (data, color) ->
  #  color = 'grey' unless color
  #  @status and console.log(data[color])

  
  # finish it up!
  opts.debug.log 'config options set'
  cb()
