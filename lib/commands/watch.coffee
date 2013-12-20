require 'colors'
open   = require 'open'
path   = require 'path'
Roots  = require '../'
Server = require '../local_server'

default_port = 1111

# TODO: this should be a class

exports.execute = (args)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  project = new Roots(dir)

  process.stdout.write('compiling... '.grey)

  server = new Server(project, dir)
  server.start(process.env.port || default_port)

  w = project.watch()

  w.on 'start', -> on_start(server)
  w.on 'error', (err) -> on_error(server, err)
  w.on 'done', -> on_done(server)
  w.once 'done', ->
    if project.config.open_browser then open("http://localhost:#{process.env.port || default_port}/")

  w

on_error = (server, err) ->
  process.stdout.write JSON.stringify(err).red
  server.show_error(err)

on_start = (server) ->
  process.stdout.write 'compiling... '.grey
  server.compiling()

on_done = (server) ->
  process.stdout.write 'done!\n'.green
  server.reload()
