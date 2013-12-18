require 'colors'
Roots = require '../'

exports.execute = (args) ->
  args = args._
  if args.length < 2 then return console.log 'help'
  
  promise = switch args[1]
    when 'add' then Roots.template.add(name: args[2], url: args[3])
    when 'remove' then Roots.template.remove(args[2])
    when 'list' then console.log Roots.template.list(pretty: true)
    when 'default' then Roots.template.default(args[2])
    when 'reset' then Roots.template.reset()

  if promise then promise.done (r) ->
    console.log r.green
  , (e) ->
    console.error "#{e}".red
