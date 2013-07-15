require "coffee-script"
path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
roots = require './index'

# load in all the core adapters
module.exports =
  jade: require './jade'
  ejs: require './ejs'
  coffee: require './coffee'
  styl: require './styl'


# load any extra plugins
plugin_path = path.join(roots.project.rootDir + "/plugins")
plugins = fs.existsSync(plugin_path) and shell.ls(plugin_path)
plugins and plugins.forEach((plugin) ->
  if plugin.match(/.+\.(?:js|coffee)$/)
    compiler = require(path.join(plugin_path, plugin))
    name = path.basename(compiler.settings.file_type)
    module.exports[name] = compiler  if compiler.settings and compiler.compile
)
