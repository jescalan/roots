Roots = require '../../../index'

module.exports = (cli, args) ->
  Roots.template.reset()
    .then(cli.emit.bind(cli, 'success'), cli.emit.bind(cli, 'err'))
