path  = require('path')
Roots = require('../')

module.exports = (args, cli)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  opts = { env: args.env || 'development' }

  cli.emit('inline', 'compiling... '.grey)

  (new Roots(dir, opts)).compile()
    .on('error', cli.emit.bind(cli, 'err'))
    .on('done', -> cli.emit('data', 'done!'.green))
