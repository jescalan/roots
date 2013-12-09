path = require 'path'
fs = require 'fs'
accord = require 'accord'
coffee = require 'coffee-script'
_ = require 'lodash'

class Config
  constructor: (@roots) ->
    @output = 'public'
    @dump_dirs = ['views', 'assets']
    @mode = 'develop'
    @debug = false
    @live_reload = true
    @open_browser = true

    load_config.call(@)

    @ignores = ['package.json', 'app.coffee', 'node_modules/**/*', "#{@output}/**/*"]
    @compilers = get_compilers.call(@)

  load_config = ->
    config_path = path.join(@roots.root, 'app')
    if not fs.existsSync("#{config_path}.coffee") then return

    # if there are exports, assume a node config file
    # otherwise, assume a default config file
    conf = require(config_path)
    if Object.keys(conf).length < 1
      conf = eval(coffee.compile(fs.readFileSync("#{config_path}.coffee", 'utf8'), { bare: true }))

    @[k] = v for k, v of conf

  output_path: ->
    path.join(@roots.root, @output)

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
        catch err
          throw new Error("'#{dep}' not found. install with `npm install #{dep} --save`")

        res[dep] = accord.load(dep, local_compiler)
    res

module.exports = Config

# What's Going On Here?
# ---------------------

# This class holds the global configuration for a roots project. It depends on the main roots
# class, and is constructed using dependency injection to hold on to a reference to the instance
# of the main roots class it was constructed under.
