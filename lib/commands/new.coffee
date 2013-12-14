require 'colors'
path = require 'path'
fs = require 'fs'
sprout = require 'sprout'
exec = require('child_process').exec

exports.execute = (args) ->
  name = args._[1]
  if not name then return console.error 'missing project name'.red

  proj_path = path.join((args._[2] || process.cwd()), name)
  tpl_name = k for k of args when k != '_' && k != '$0'
  tpl_name ?= 'base'

  
  # if there are no templates, inject base
  base_url = 'https://github.com/roots-dev/base.git'
  if sprout.commands.list().length < 1
    sprout.commands.add('base', base_url,-> init(tpl_name, proj_path))
  else
    init(tpl_name, proj_path)

init = (name, p) ->
  sprout.commands.init name, p, (err) ->
    if err then return console.error(err.red)

    console.log "new project created at #{p.replace(process.cwd(), '')}"
    console.log "(using #{name} template)".grey

    # install deps
    if not fs.existsSync(path.join(p, 'package.json')) then retur
    process.stdout.write '\ninstalling dependencies...'.grey
    exec "cd #{p}; npm install", -> process.stdout.write ' done!\n'.green
