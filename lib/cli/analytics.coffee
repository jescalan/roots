W     = require 'when'
Roots = require '../../lib'

module.exports = (cli, args) ->
  Roots.analytics(args)
  cli.emit('success', 'analytics settings updated!')
  W.resolve()
