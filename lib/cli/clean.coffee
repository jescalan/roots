Roots = require '../../lib'
rimraf = require 'rimraf'

###*
 * Simple wrapper for Roots.clean, emits events and data to the cli.
 *
 * @param  {CLI} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the removed output
###

module.exports = (cli, args) ->
  __track('commands', name: 'clean')
  project = new Roots(args.path)
  project.clean()
    .then -> cli.emit('success', 'output removed')
    .catch (err) -> cli.emit('err', err); throw err
