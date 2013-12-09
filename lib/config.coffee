path = require 'path'
fs = require 'fs'
accord = require 'accord'

class Config
  constructor: (@roots) ->

    @dirs =
      output: 'public'
      views: 'views'
      assets: 'assets'

    @mode = 'develop'
    @debug = false
    @live_reload = true
    @open_browser = true

    @ignores = ['package.json', 'node_modules/**/*', "#{@dirs.output}/**/*"]
    @compilers = get_compilers.call(@)

  path: (name) ->
    path.join(@roots.root, @dirs[name])

  compress: ->
    @mode == 'develop'

  # @api private

  get_compilers = ->
    res = {}
    pkg_json_path = path.join(@roots.root, 'package.json')
    if not fs.existsSync(pkg_json_path) then return res

    pkg = require(pkg_json_path)
    for dep in Object.keys(pkg.dependencies)
      if accord.supports(dep)
        try
          local_compiler = require(path.join(@roots.root, 'node_modules', dep))
        catch
          throw new Error("'#{dep}' not found. install with `npm install #{dep} --save`")

        res[dep] = accord.load(dep, local_compiler)
    res

module.exports = Config

# What's Going On Here?
# ---------------------

# This class holds the global configuration for a roots project. It depends on the main roots
# class, and is constructed using dependency injection to hold on to a reference to the instance
# of the main roots class it was constructed under.
