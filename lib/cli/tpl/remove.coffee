Roots = require '../../../index'

module.exports = (cli, args) ->
  Roots.template.remove(args)
    .then(cli.emit.bind(cli, 'success'), cli.emit.bind(cli, 'err'))
