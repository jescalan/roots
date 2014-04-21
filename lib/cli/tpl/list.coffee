Roots = require '../../../lib'

###*
 * Simple wrapper for Roots.template.list, emits data to the CLI.
 *
 * @param  {CLI} cli - CLI class instance for event emission
 * @param  {Object} args - arguments to be sent to the roots fn
 * @return {String}
###

module.exports = (cli, args) ->
  list = Roots.template.list(pretty: true)
  cli.emit('data', list)
  return list
