antimatter = require 'anti-matter'
Roots = require '../'

module.exports = (args, cli) ->
  args = args._
  if args.length < 2 then return cli.emit('data', help())

  promise = switch args[1]
    when 'add' then Roots.template.add(name: args[2], uri: args[3])
    when 'remove' then Roots.template.remove(name: args[2])
    when 'list' then cli.emit('data', Roots.template.list(pretty: true))
    when 'default' then Roots.template.default(args[2])
    when 'reset' then Roots.template.reset()

  if promise.then then promise.done (r) ->
    cli.emit('data', r.green)
  , (e) ->
    cli.emit('err', "#{e}".red)

help = ->
  antimatter
    title: 'Roots Templates'
    options: { width: 65, color: 'blue' }
    commands: [{
      name: 'add'
      required: ['name', 'url']
      description: 'Adds a new roots template called [name], located at [url], which is any url that can be "git clone"-d'
    }, {
      name: 'remove'
      required: ['name']
      description: 'Removed the template with the given [name]'
    }, {
      name: 'list'
      description: 'Lists all installed roots templates'
    }, {
      name: 'default'
      required: ['name']
      description: 'Makes the template [name] the default template whenever `roots new` is run'
    }]
