W      = require 'when'
fs     = require 'fs'
path   = require 'path'
Ship   = require 'ship'
Config = require '../config'

class Deploy
  constructor: (@project) ->

  exec: (opts = {}) ->
    __track('api', { name: 'deploy', deployer: opts.to })

    @project.clean()
    .then => @project.compile()
    .then =>
      if fs.existsSync(path.join(@project.root, 'ship.production.conf'))
        new Ship(root: @project.root, deployer: opts.to, env: 'production')
      else
        new Ship(root: @project.root, deployer: opts.to)
    .tap (ship) ->
      if not ship.is_configured()
        ship.config_prompt()
          .tap (values) -> ship.config = values
          .then -> ship.write_config()
    .tap (ship) => ship.deploy(@project.config.output_path())

module.exports = Deploy
