require 'colors'
open = require 'open'
path = require 'path'
Roots = require '../'
Server = require '../local_server'
chokidar = require 'chokidar'
minimatch = require 'minimatch'

exports.execute = (args)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  project = new Roots(dir)

  process.stdout.write('compiling... '.grey)
  (new Server(dir)).start()

  w = project.watch()

  w.on 'start', onStart
  w.on 'error', onError
  w.on 'done', onDone

  w

onError = (err) ->
  process.stdout.write JSON.stringify(err).red

onStart = ->
  process.stdout.write 'compiling... '.grey

onDone = ->
  open 'http://localhost:1111/'
  process.stdout.write 'done!\n'.green
