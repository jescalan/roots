path = require 'path'
Roots = require '../'
rimraf = require 'rimraf'

module.exports = (args, cli) ->
  project = new Roots(path.normalize(args._[1] or process.cwd()))
  output_path = project.config.output_path()
  rimraf.sync(output_path)
  cli.emit('data', "\nRemoved #{output_path}\n".green)
