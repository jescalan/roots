roots = require("../index")
path = require("path")
shell = require("shelljs")
_compile = (args) ->
  global.options.compress = true  if args["compress"] is `undefined`
  shell.rm "-rf", path.join(roots.project.rootDir, options.output_folder)
  roots.compile_project roots.project.rootDir, ->

  args["compress"] is `undefined` and process.stdout.write("\nminifying & compressing...\n".grey)

module.exports =
  execute: _compile
  needs_config: true
