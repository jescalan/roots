Roots = require('../../index')

module.exports = (cli, args)->
  project = new Roots(args.path, { env: args.environment })

  cli.emit('inline', 'compiling... '.grey)

  project.compile().then ->
    cli.emit('data', 'done!'.green)
  , (err) ->
    cli.emit('err', Error(err).stack)
