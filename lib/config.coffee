path = require 'path'
fs = require 'fs'

class Config
  constructor: (root) ->
    @root = path.normalize(root)

    @dirs =
      output: 'public'
      views: 'views'
      assets: 'assets'

    @mode = 'develop'
    @debug = false
    @live_reload = true
    @open_browser = true

    @ignores = ['package.json', 'node_modules/**/*', @dirs.output]
    @compilers = get_compilers.call(@)

  path: (name) ->
    path.join(@root, @dirs[name])

  compress: ->
    @mode == 'develop'

  # @api private

  get_compilers = ->
    res = {}
    pkg = require(path.join(@root, 'package.json'))
    for dep in Object.keys(pkg.dependencies)
      # get accord adapter, add second arg to do a local require
      # if accord.supports(dep) then res[dep] = accord.load(dep)
      cpath = path.join(__dirname, 'adapters', dep)
      if fs.existsSync("#{cpath}.coffee") then res[dep] = require(cpath)
    res

class Singleton
  instance = null

  @setup: (root) ->
    if instance then throw 'config has already been set up'
    instance = new Config(root)

  @get: -> instance
  @path: (name) -> instance.path(name)

  @set: (obj) ->
    instance[k] = v for k, v of obj
    return obj

global.config = Singleton

# What's Going On Here?
# ---------------------

# This class holds the global configuration for a roots project. It is a singleton,
# meaning that it will always return the same object whenever initialized. It comes
# with a number of default settings but can also be configured using the `setup` method.
# Config values can be changed using the `set` method, but be careful.

# This class is placed on the global object to avoid the overhead of having to require
# the entire index file and all it's dependencies whenever access to the config variables
# is needed. In a previous refactor we handled config like that, but there was a noticeable
# slowdown due to the fact that loading the config meant loading every file and dependency
# in the entire project, which is not necessary when you just need access to the configuration.
# The config is global, which is why attaching it to the global object is appropriate in this
# situation, although in general the use of global objects is discouraged. And because it is a
# singleton which requires initialization before use, it is much easier to track which parts of
# the program are using or changing it then simply using a raw global object.
