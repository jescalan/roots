Roots = require '../../index'
rimraf = require 'rimraf'

module.exports = (cli, args) ->
  project = new Roots(args.path)
  # TODO: this should be `project.clean()` and probably be async
  rimraf.sync(project.config.output_path())
  cli.emit('success', 'output removed')
