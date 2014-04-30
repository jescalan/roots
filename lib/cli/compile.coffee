Roots = require '../../lib'

###*
 * Simple wrapper for Roots.compile, emits events and data to the cli.
 *
 * @param  {CLI} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the compiled project
###

module.exports = (cli, args)->
  project = new Roots(args.path, { env: args.environment })

  cli.emit('inline', 'compiling... '.grey)
  if args.verbose then cli.emit('data', '')

  project.compile()
    .progress (msg) -> if args.verbose then cli.emit('info', msg)
    .then -> cli.emit('data', 'done!'.green)
    .catch -> cli.emit('err', Error(err).stack); throw err
