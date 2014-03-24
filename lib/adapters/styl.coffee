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
    'include css': true
  )

  # patching stylus warnings to actually show like regular errors
  warnings     = []
  originalWarn = console.warn;
  console.warn = (prefix, warning) -> warnings.push(warning)

  transformer.render file.contents, options, (err, res) ->
    if warnings.length and not err?
      err = new Error("Stylus Compile Warnings(s) #{warnings.join('\n')}")

    # restore console.warn
    console.warn = originalWarn

    cb(err, res)

  return
