config = require("../global_config")
path = require("path")
fs = require("fs")
shell = require("shelljs")
colors = require("colors")

usage = ->
  console.log """
    #{'usage:'.blue}
    - #{'add [name] [github_url]:'.bold} add a new roots template
    - #{'default [name]:'.bold} make this template the default
  """

_template = (args) ->
  cmd = args._[1]
  switch cmd
    when "add"
      if args._.length < 4
        usage()
        break
      pair = {}
      name = args._[2]
      url = args._[3]
      pair[name] = url
      config.modify "templates", pair
    when "default"
      if args._.length < 3
        usage()
        break
      config.modify "templates",
        default: args._[2]

    when "remove"
      config.remove "templates", args._[2]
    else
      usage()

module.exports = execute: _template
