require 'colors'
path = require 'path'
Roots = require '../'
chokidar = require 'chokidar'
minimatch = require 'minimatch'

exports.execute = (args)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  project = new Roots(dir)

  process.stdout.write('compiling... '.grey)
  
  project.watch()
    .on('start', -> process.stdout.write('compiling... '.grey))
    .on('error', console.error.bind(console))
    .on('done', -> process.stdout.write('done!\n'.green))
