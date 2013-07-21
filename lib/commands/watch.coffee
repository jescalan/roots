path = require("path")
fs = require("fs")
_ = require("underscore")
minimatch = require("minimatch")
yaml_parser = require("../utils/yaml_parser")
watcher = require("../watcher")
roots = require("../index")
server = require("../server")
colors = require("colors")

output_path = require("../utils/output_path")
compiler = roots.compiler
roots.project.rootDir = roots.project.rootDir
_watch = ->
  
  # add in the livereload function
  
  # compile once and run the local server when ready
  
  # watch the project for changes and reload
  watch_function = (file) ->
    server.compiling()

    # make sure the file wasn't deleted
    if not fs.existsSync(file.fullPath)
      # if the changed file was deleted, just remove it in the public folder
      try
        fs.unlinkSync(output_path(file.fullPath))
      catch e
        console.log "Error Unlinking File".inverse.red
        console.log e

      server.reload()
      return

    # if there was an error, the whole project needs to be recompiled to get
    # rid of the error message
    if global.options.error then return roots.compile_project 'error'

    # if it's a dynamic file, the entire project needs to be recompiled
    # so that references to it show up in other files
    if yaml_parser.detect(file.fullPath)
      return roots.compile_project 'dynamic file'

    # ignored files that are modified are often dependencies for another non-
    # ignored file. Until we have an asset graph in this project, the safest
    # approach is to recompile the whole project when an ignored file is
    # modified.
    ignored = global.options.ignoreFiles
    i = 0

    while i < ignored.length
      if minimatch(path.basename(file.path), ignored[i].slice(1))
        options.debug.log "ignored file changed, reloading project"
        return roots.compile_project(roots.project.rootDir, server.reload)
      i++

    compile_single_file file.fullPath

  socket_script = "<script>" + fs.readFileSync(path.join(__dirname, "../../templates/reload/reload.min.js"), "utf8") + "</script>"
  spinner_html = fs.readFileSync(path.join(__dirname, "../../templates/reload/spinner.html"))
  global.options.locals.livereload = socket_script + spinner_html
  compiler.mode = "dev"
  roots.compile_project roots.project.rootDir, ->
    server.start roots.project.rootDir

  watcher.watch_directory roots.project.rootDir, _.debounce(watch_function, 500)

module.exports =
  execute: _watch
  needs_config: true
