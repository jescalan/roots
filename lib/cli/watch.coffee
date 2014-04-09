open   = require 'open'
path   = require 'path'
Roots  = require '../'
Server = require '../local_server'

default_port = 1111

module.exports = (args, cli) ->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  opts = { env: args.env || 'development' }
  project = new Roots(dir, opts)
  args.open ?= true

  cli.emit('inline', 'compiling... '.grey)

  server = new Server(project, dir)
  server.start(process.env.port || default_port)

  w = project.watch()

  w.on 'start', -> on_start(cli, server)
  w.on 'error', (err) -> on_error(cli, server, err)
  w.on 'done', -> on_done(cli, server)
  w.once 'done', ->
    if project.config.open_browser and args.open
      open("http://localhost:#{process.env.port || default_port}/")

  w

on_error = (cli, server, err) ->
  cli.emit('err', "\n\nERROR\n-----\n".red)
  cli.emit('err', err.stack)
  server.show_error(err.stack)

on_start = (cli, server) ->
  cli.emit('inline', 'compiling... '.grey)
  server.compiling()

on_done = (cli, server) ->
  cli.emit('inline', 'done!\n'.green)
  server.reload()
