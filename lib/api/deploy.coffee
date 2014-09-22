W    = require 'when'
Ship = require 'ship'

class Deploy
  constructor: (@project) ->

  exec: (opts = {}) ->
    __track('api', { name: 'deploy', deployer: opts.to })

    @project.compile()
    .then => new Ship(root: @project.root, deployer: opts.to)
    .tap (ship) ->
      if not ship.is_configured()
        ship.config_prompt()
          .tap (values) -> ship.config = values
          .then -> ship.write_config()
    .tap (ship) => ship.deploy(@project.config.output_path())

module.exports = Deploy
