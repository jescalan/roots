Roots = require '../../index'
rimraf = require 'rimraf'

###*
 * Simple wrapper for Roots.clean, emits events and data to the cli.
 *
 * @param  {EventEmitter} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the removed output
###

module.exports = (cli, args) ->
  project = new Roots(args.path)
  project.clean()
    .then(cli.emit.bind(cli, 'success', 'output removed'), cli.emit.bind(cli, 'err'))
