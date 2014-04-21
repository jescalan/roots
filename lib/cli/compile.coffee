Roots = require '../../index'

###*
 * Simple wrapper for Roots.compile, emits events and data to the cli.
 *
 * @param  {EventEmitter} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the compiled project
###

module.exports = (cli, args)->
  project = new Roots(args.path, { env: args.environment })

  cli.emit('inline', 'compiling... '.grey)

  project.compile().then ->
    cli.emit('data', 'done!'.green)
  , (err) ->
    cli.emit('err', Error(err).stack)
