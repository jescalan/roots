colors = require("colors")
async = require("async")
shell = require("shelljs")
path = require("path")
fs = require("fs")
_ = require("underscore")
readdirp = require("readdirp")
minimatch = require("minimatch")
Q = require("q")
deferred = Q.defer()
add_error_messages = require("./utils/add_error_messages")
output_path = require("./utils/output_path")
yaml_parser = require("./utils/yaml_parser")
precompile_templates = require("./precompiler")
Compiler = require("./compiler")

# initialization and error handling
compiler = new Compiler()
_.bindAll compiler

compiler.on "error", (err) ->
  console.log "\u0007" # bell sound
  console.error "\n\n------------ ERROR ------------\n\n".red + err.stack + "\n"
  add_error_messages.call this, err, @finish


# @api public
# Given a root (folder or file), compile with roots and output to /public
exports.compile_project = (root, done) ->
  compiler.once "finished", ->
    process.stdout.write "done!\n".green
    done()

  process.stdout.write "compiling... ".grey
  global.options.debug.log ""
  analyze(root).then(create_folders).then(compile).then(precompile_templates).then compiler.finish, (err) ->
    compiler.emit "error", err


# @api private
# parse file/directory input and generate mini roots-style AST.
analyze = (root) ->
  parse_directory = (root) ->
    
    # clear the dynamic locals first
    global.options.locals.site = null
    
    # read through the current project and organize the files
    options =
      root: root
      directoryFilter: global.options.ignore_folders
      fileFilter: global.options.ignore_files

    readdirp options, (err, res) ->
      console.error err  if err
      
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
    minimatch file, "**/" + global.options.templates + "/*"
  global.options.debug.log "analyzing project", "yellow"
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
  global.options.debug.log "compiling and copying files", "yellow"
  async.map ast.dynamic_files, compiler.compile, (err1) ->
    async.parallel [compile_files, copy_static_files], (err2) ->
      deferred.reject err  if err1 or err2
      deferred.resolve ast

  deferred.promise

# @api private
# create the folder structure for the project
create_folders = (ast) ->
  global.options.debug.log "creating folders", "yellow"
  shell.mkdir "-p", path.join(process.cwd(), options.output_folder)
  for key of ast.folders
    shell.mkdir "-p", output_path(ast.folders[key])
    global.options.debug.log "created " + ast.folders[key].replace(process.cwd(), "")
  Q.fcall ->
    ast

