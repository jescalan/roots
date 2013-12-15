require 'colors'
path = require 'path'
Roots = require '../'

exports.execute = (args) ->
  name = args._[1]
  if not name then return console.error 'missing project name'.red
  proj_path = path.join((args._[2] || process.cwd()), name)
  tpl_name = k for k of args when k != '_' && k != '$0'
  tpl_name ?= 'base'

  Roots.new(tpl_name, proj_path)
    .on('template:created', ->
      console.log "new project created at #{proj_path.replace(process.cwd(), '')}"
      console.log "(using #{name} template)".grey
    )
    .on('deps:installing', -> process.stdout.write '\ninstalling dependencies...'.grey)
    .on('deps:finished', -> process.stdout.write ' done!\n'.green)
    .on('error', console.error.bind(console))
