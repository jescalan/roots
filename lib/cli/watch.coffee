open   = require 'open'
Roots  = require '../../index'
Server = require '../local_server'

module.exports = (cli, args) ->
  project = new Roots(args.path, { env: args.environment })
  server  = new Server(project, project.root)
  port    = process.env.port or args.port

  cli.emit('inline', 'compiling... '.grey)
  server.start(port)

  watcher = project.watch()

  watcher.on('start', on_start.bind(null, cli, server))
  watcher.on('error', on_error.bind(null, cli, server))
  watcher.on('done', on_done.bind(null, cli, server))

  watcher.once 'done', ->
    if project.config.open_browser and not args.no_open
      open("http://localhost:#{port}/")

  return { server: server, watcher: watcher }

on_error = (cli, server, err) ->
  cli.emit('err', Error(err).stack)
  server.show_error(Error(err).stack)

on_start = (cli, server) ->
  cli.emit('inline', 'compiling... '.grey)
  server.compiling()

on_done = (cli, server) ->
  cli.emit('data', 'done!'.green)
  server.reload()
