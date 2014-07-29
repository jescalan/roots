global_config = require '../global_config'

###*
 * Enables or disabled analytics via the global settings.
 * @param  {Object} args - { enable: true } or { disable: true }
###

module.exports = (args) ->
  conf = global_config()
  if args.disable then conf.set('analytics', false)
  if args.enable then conf.set('analytics', true)
