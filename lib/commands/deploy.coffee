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
  if args._.length > 1 then name = args._[1]
  
  # deploy it!
  deploy_steps = [
    'check_install_status'
    'check_credentials'
    'compile_project'
    'add_config_files'
    'commit_files'
    'create_project'
    'push_code'
  ]

  d = new Deployer(adapter, name)
  _.bindAll.apply(this, [d].concat(deploy_steps))

  deploy_functions = deploy_steps.map((s) -> d[s])

  async.series deploy_steps, (err) ->
    if err then return console.error(err)
    console.log "done!".green


module.exports =
  execute: _deploy
  needs_config: true
