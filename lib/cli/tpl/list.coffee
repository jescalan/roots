Roots = require '../../../index'

module.exports = (cli, args) ->
  cli.emit('data', Roots.template.list(pretty: true))
