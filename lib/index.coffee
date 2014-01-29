colors = require 'colors'
path = require 'path'
async = require 'async'
shell = require 'shelljs'
fs = require 'fs'
_ = require 'underscore'
readdirp = require 'readdirp'
minimatch = require 'minimatch'
W = require 'when'
fn = require 'when/function'

Project = require './project'
project = exports.project = new Project(process.cwd())
yaml_parser = require './utils/yaml_parser'
precompile_templates = require './precompiler'
Compiler = require './compiler'
printers = exports.printers = require './print'
print = exports.print = new printers.Print()
terminalPrinter = new printers.TerminalPrinter()
compiler = exports.compiler = new Compiler()

###*
 * parse file/directory input and generate mini roots-style AST.
 * @private
###
analyze = (root) ->
  parse_directory = (root) ->
    deferred = W.defer()
    # clear the dynamic locals first
    project.locals.site = null
    # read through the current project and organize the files
    options =
      root: root
      directoryFilter: project.ignore_folders
      fileFilter: project.ignore_files

    readdirp options, (err, res) ->
      print.error err if err
      # populate folders
      ast.folders = _.pluck(res.directories, 'fullPath')
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
    project.extensions.indexOf(path.extname(file).slice(1)) >= 0

  is_template = (file) ->
    minimatch file, '**/' + project.templates + '/*'

  print.debug 'analyzing project', 'yellow'
  ast =
    folders: {}
    compiled_files: []
    static_files: []
    dynamic_files: []

  return parse_directory(root) if fs.statSync(root).isDirectory()
  parse_file root
  return ast

###*
 * create the folder structure for the project
 * @private
###
create_folders = (ast) ->
  print.debug 'creating folders', 'yellow'
  shell.mkdir '-p', project.path('public')
  output_path = require('./utils/output_path')
  for key of ast.folders
    shell.mkdir '-p', output_path(ast.folders[key])
    print.debug "created #{ast.folders[key].replace(project.rootDir, '')}"
  ast

###*
 * compile and write the files given a roots AST.
 * @private
###
compile = (ast) ->
  # compile dynamic content first, if present
  compile_files = (cb) ->
    async.map ast.compiled_files, compiler.compile, cb

  copy_static_files = (cb) ->
    async.map ast.static_files, compiler.copy, cb

  deferred = W.defer()
  print.debug 'compiling and copying files', 'yellow'
  async.map ast.dynamic_files, compiler.compile, (err) ->
    async.parallel [compile_files, copy_static_files], ->
      deferred.resolve ast

  deferred.promise

_.bindAll compiler, 'compile', 'copy', 'finish'

compiler.on 'error', (err) ->
  print.error err
  compiler.finish()

###*
 * Given a root (folder or file), compile with roots and output to /public
 * @public
###
exports.compile_project = (root, done, errback) ->
  compiler.once 'finished', done
  compiler.on 'error', errback  if errback?
  fn.call(analyze, root).then((ast) ->
    fn.lift(create_folders, ast)()
  ).then(compile).then(precompile_templates).otherwise((err) ->
    compiler.emit 'error', err
  ).then compiler.finish
