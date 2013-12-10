path = require('path')
Roots = require('../')

exports.execute = (args)->
  dir = if args._[1] then path.resolve(args._[1]) else process.cwd()

  (new Roots(dir)).compile()
    .on('error', console.error.bind(console))
    .on('done', -> console.log('done!'))
