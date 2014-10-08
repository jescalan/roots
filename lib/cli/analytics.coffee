W     = require 'when'
Roots = require '../../lib'

module.exports = (cli, args) ->
  __track('commands', name: 'analytics')
  Roots.analytics(args)
  cli.emit('success', 'analytics settings updated!')
  W.resolve()
