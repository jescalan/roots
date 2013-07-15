fs = require("fs")
shell = require("shelljs")
path = require("path")
roots = require("../index")
run = require("child_process").exec
colors = require("colors")
_plugin = (args) ->
  cmd = args._[1]
  
  # create plugins directory if it doesn't exist already
  plugin_folder_path = path.join(roots.project.rootDir, "plugins")
  not fs.existsSync(plugin_folder_path) and fs.mkdirSync(plugin_folder_path)
  
  # generate a new plugin template
  if cmd is "generate"
    source = path.join(__dirname, "../../templates/plugin/template.coffee")
    destination = path.join(roots.project.rootDir, "plugins/")
    source = path.join(__dirname, "../../templates/plugin/template.js")  if args.js
    shell.cp "-r", source, destination
    console.log "\nplugin template generated at `/plugins`\n".green
  
  # install a roots plugin from git repo
  else if cmd is "install"
    if args._.length < 3
      return console.error("please provide a github username/repo")
    else
      repo_string = args._[2]
    plugin_dir = path.join(roots.project.rootDir, "plugins", repo_string.replace(/.*\//, ""))
    run "git clone https://github.com/" + repo_string + " " + plugin_dir, (err) ->
      return process.stdout.write(err.toString().red)  if err
      console.log repo_string.green + " installed!".green

  
  # help
  else
    console.log "\nusage:\n".blue
    process.stdout.write "- " + "generate: ".bold + "generate a coffeescript plugin template. `--js` for javascript\n"
    process.stdout.write "- " + "install <username/repo>: ".bold + "install a plugin from a github repo\n\n"

module.exports = execute: _plugin
