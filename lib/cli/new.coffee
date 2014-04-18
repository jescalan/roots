Roots = require '../../index'

module.exports = (cli, args) ->
  Roots.new(args)
    .progress((i) -> cli.emit('info', i))
    .then (roots) ->
      cli.emit('info', "project initialized at #{roots.root}")
      cli.emit('info', "using template: #{args.template || 'roots-base'}")
      cli.emit('success', 'done!')
    , (err) ->
      cli.emit('err', err)
