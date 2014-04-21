Roots = require '../../index'

###*
 * Simple wrapper for Roots.new, emits events and data to the cli.
 *
 * @param  {EventEmitter} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the created project
###

module.exports = (cli, args) ->
  Roots.new(args)
    .progress((i) -> cli.emit('info', i))
    .then (roots) ->
      cli.emit('info', "project initialized at #{roots.root}")
      cli.emit('info', "using template: #{args.template || 'roots-base'}")
      cli.emit('success', 'done!')
    , (err) ->
      cli.emit('err', err)
