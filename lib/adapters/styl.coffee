roots = require '../index'
transformer = require('transformers')['stylus']
_ = require 'underscore'

# configure plugins
opts = roots.project.compiler_options.stylus
plugins = []
for plugin in opts.plugins
  p = if typeof plugin == 'string' then require(plugin) else plugin
  plugins.push(p)

exports.settings =
  file_type: 'styl'
  target: 'css'

exports.compile = (file, options={}, cb) ->
  _.defaults(options,
    inline: roots.project.conf 'compress'
    filename: file.path
    use: plugins
  )

  transformer.render(file.contents, options, cb)
  return
