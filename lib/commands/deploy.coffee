shell = require("shelljs")
async = require("async")
_ = require("underscore")
path = require("path")
colors = require("colors")
Deployer = require("../deployer")

_deploy = (args) ->
  custom_adapter = undefined
  for k of args
    custom_adapter = k  if k isnt "_" and k isnt "$0"
  if custom_adapter
    try
      adapter = require(path.join("../deploy_recipes/" + custom_adapter))
    catch err
      return console.log("deploy adapter not found".red)
  else
    adapter = require("../deploy_recipes/heroku")
  
  # set name if present
  name = ""
  name = opts[0]  if opts.length > 0
  
  # deploy it!
  d = new Deployer(adapter, name)
  _.bindAll d
  deploy_steps = [d.check_install_status, d.check_credentials, d.compile_project, d.add_config_files, d.commit_files, d.create_project, d.push_code]
  async.series deploy_steps, (err) ->
    return console.error(err)  if err
    console.log "done!".green


module.exports =
  execute: _deploy
  needs_config: true
