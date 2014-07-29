global_config = require '../global_config'

###*
 * Enables or disabled analytics via the global settings.
 * @param  {Object} args - { enable: true } or { disable: true }
###

module.exports = (args) ->
  if args.disable then global_config.set('analytics', false)
  if args.enable then global_config.set('analytics', true)
