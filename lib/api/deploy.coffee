W    = require 'when'
Ship = require 'ship'

class Deploy
  constructor: (@project) ->

  exec: (opts = {}) ->
    @project.compile()
    .then => new Ship(root: @project.root, deployer: opts.to)
    .tap (ship) ->
      if not ship.is_configured()
        ship.config_prompt().then(ship.write_config.bind(ship))
    .tap (ship) => ship.deploy(@project.config.output_path())

module.exports = Deploy
