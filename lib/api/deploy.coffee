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
    .then =>
      # So in reality, compile should take an env parameter. It does not at the
      # moment though probably for performance reasons, so we can hack around
      # this to get a compile in a different env. This should be refactored.
      if fs.existsSync(path.join(@project.root, 'app.production.coffee'))
        @project.config = new Config(@project, { env: 'production' })
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
