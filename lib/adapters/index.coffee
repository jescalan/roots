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

console.log roots

# load any extra plugins
plugins = fs.existsSync() and shell.ls(roots.project.path('plugins'))

plugins and plugins.forEach((plugin) ->
  if plugin.match(/.+\.(?:js|coffee)$/)
    compiler = require(path.join(roots.project.path('plugins'), plugin))
    name = path.basename(compiler.settings.file_type)
    if compiler.settings and compiler.compile
      module.exports[name] = compiler
)
recursive_readdir(roots.project.path('plugins'), (err, files) =>
  if err then roots.print.error err
  for file in files
    @addAsset file

  cb()
)
