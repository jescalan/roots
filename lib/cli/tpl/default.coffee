Roots = require '../../../lib'

###*
 * Simple wrapper for Roots.template.default, emits data to the CLI.
 *
 * @param  {CLI} cli - CLI class instance for event emission
 * @param  {Object} args - arguments to be sent to the roots fn
 * @return {Promise}
###

module.exports = (cli, args) ->
  Roots.template.default(args)
    .then(cli.emit.bind(cli, 'success'))
    .catch((err) -> cli.emit('err', err); throw err)
