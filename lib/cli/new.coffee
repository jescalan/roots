path = require 'path'
Roots = require '../'

module.exports = (args, cli) ->
  name = args._[1]
  if not name then return cli.emit('err', 'missing project name'.red)
  proj_path = path.join((args._[2] || process.cwd()), name)
  tpl_name = k for k of args when k != '_' && k != '$0'

  Roots.new(name: name, path: proj_path, template: tpl_name)
    .on('template:created', ->
      cli.emit('data', "new project created at #{proj_path.replace(process.cwd(), '').slice(1)}".green)
      cli.emit('data', "(using #{tpl_name or 'base'} template)".grey)
    )
    .on('deps:installing', -> cli.emit('data', '\ninstalling dependencies... '.grey))
    .on('deps:finished', -> cli.emit('data', 'done!\n'.green))
    .on('error', cli.emit.bind(cli, 'err'))
