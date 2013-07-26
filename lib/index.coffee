#async = require("async")
#shell = require("shelljs")
#path = require("path")
#fs = require("fs")
#_ = require("underscore")
#readdirp = require("readdirp")
#minimatch = require("minimatch")
#Q = require("q")
#deferred = Q.defer()
#add_error_messages = require("./utils/add_error_messages")
#yaml_parser = require("./utils/yaml_parser")
#precompile_templates = require("./precompiler")

Print = require './print'
exports.print = new Print()

Project = require './project'
exports.project = new Project(process.cwd())

Adapters = require './adapters'
exports.adapters = new Adapters()

# load in all the core adapters
for adapter in ['jade', 'ejs', 'coffee', 'styl']
  RequiredAdapter = require("./adapters/#{adapter}")
  exports.adapters.registerAdapter(
    new RequiredAdapter()
  )

# load any extra plugins
plugins = fs.existsSync() and shell.ls(roots.project.path('plugins'))

plugins and plugins.forEach((plugin) ->
  if plugin.match(/.+\.(?:js|coffee)$/)
    compiler = require(path.join(roots.project.path('plugins'), plugin))
    name = path.basename(compiler.settings.file_type)
    if compiler.settings and compiler.compile
      module.exports[name] = compiler
)
recursiveReaddir(roots.project.path('plugins'), (err, files) =>
  if err then roots.print.error err
  for file in files
    @addAsset file

  cb()
)

Server = require './server'
exports.server = new Server(process.env.PORT or 1111, false)

Compiler = require './compiler' # temporary
exports.compiler = new Compiler() # temporary

exports.project.getInitalFiles(->
  exports.print.log exports.project.assets
)


###
 initialization and error handling
_.bindAll compiler

# @api public
# Given a root (folder or file), compile with roots and output to /public
exports.compile_project = (root, done) ->
  compiler.once "finished", ->
    process.stdout.write "done!\n".green
    done()

  process.stdout.write "compiling... ".grey
  print.debug ""
  analyze(root).then(create_folders).then(compile).then(precompile_templates).then compiler.finish, (err) ->
    compiler.emit "error", err


# @api private
# parse file/directory input and generate mini roots-style AST.
analyze = (root) ->
  parse_directory = (root) ->
    
    # clear the dynamic locals first
    global.options.locals.site = null
    
#    # read through the current project and organize the files
#    options =
#      root: root
#      directoryFilter: global.options.ignore_folders
#      fileFilter: global.options.ignoreFiles

    readdirp options, (err, res) ->
      console.error err if err
      
      # populate folders
      ast.folders = _.pluck(res.directories, "fullPath")
      
      # populate compiled and copied files
      res.files.forEach (file) ->
        parse_file file.fullPath
      deferred.resolve ast
    deferred.promise

  parse_file = (file) ->
    if yaml_parser.detect(file)
      ast.dynamic_files.push file
    else if is_template(file)
      false
    else if is_compiled(file)
      ast.compiled_files.push file
    else
      ast.static_files.push file
  is_compiled = (file) ->
    global.options.compiled_extensions.indexOf(path.extname(file).slice(1)) >= 0
  is_template = (file) ->
###
    #minimatch file, "**/" + global.options.templates + "/*"
###
  print.debug "analyzing project", "yellow"
  ast =
    folders: {}
    compiled_files: []
    static_files: []
    dynamic_files: []

  if fs.statSync(root).isDirectory()
    return parse_directory(root)
  else
    parse_file root
    return Q.fcall(->
      ast
    )

# @api private
# compile and write the files given a roots AST.
compile = (ast) ->
  
  # compile dynamic content first, if present
  compile_files = (cb) ->
    async.map ast.compiled_files, compiler.compile, cb
  copy_static_files = (cb) ->
    async.map ast.static_files, compiler.copy, cb
  print.debug "compiling and copying files", "yellow"
  async.map ast.dynamic_files, compiler.compile, (err1) ->
    async.parallel [compile_files, copy_static_files], (err2) ->
      deferred.reject err  if err1 or err2
      deferred.resolve ast

  deferred.promise

# @api private
# create the folder structure for the project
create_folders = (ast) ->
  print.debug "creating folders", "yellow"
  shell.mkdir "-p", path.join(roots.project.rootDir, options.output_folder)
  for key of ast.folders
    shell.mkdir "-p", output_path(ast.folders[key])
    print.debug "created " + ast.folders[key].replace(roots.project.rootDir, "")
  Q.fcall ->
    ast

###
