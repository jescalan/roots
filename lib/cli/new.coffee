Roots = require '../../lib'

###*
 * Simple wrapper for Roots.new, emits events and data to the cli.
 *
 * @param  {CLI} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the created project
###

module.exports = (cli, args) ->
  __track('commands', { name: 'new', template: args.template })

  Roots.new(args)
    .progress((i) -> cli.emit('info', i))
    .then (roots) ->
      cli.emit('info', "project initialized at #{roots.root}")
      cli.emit('info', "using template: #{args.template ? 'roots-base'}")
      cli.emit('success', 'done!')
    .catch (err) -> cli.emit('err', err); throw err
