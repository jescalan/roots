path  = require('path')
Roots = require('../')

exports.execute = (args)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()
  opts = { env: args.env || 'development' }

  process.stdout.write('compiling... '.grey)

  (new Roots(dir, opts)).compile()
    .on('error', console.error.bind(console))
    .on('done', -> console.log('done!'.green))
