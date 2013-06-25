colors = require 'colors'
shell = require 'shelljs'
roots = require './index'

# Template class for deploy recipes
class Deployer 
  constructor: (adapter, name) ->
    @adapter = adapter
    @name = (if name.length < 1 then '' else name)
    @add_shell_method = (name) ->
      add_method adapter, name

    # template methods
    @add_shell_method 'check_install_status'
    @add_shell_method 'check_credentials'
    @add_shell_method 'add_config_files'
    @add_shell_method 'create_project'
    @add_shell_method 'push_code'

  # A couple functions that are the same across all adapters (currently)

  compile_project: (cb) ->
    roots.compile_project process.cwd(), ->
      cb()

  commit_files: (cb) ->
    cmd = shell.exec('git add .; git commit -am \'compress and deploy\'')
    console.log 'project committed to git'.grey
    cb()

module.exports = Deployer

# @api private
add_method = (adapter, name) ->
  Deployer::[name] = (
    if not adapter[name]? then ((cb) -> cb()) else adapter[name]
  )
