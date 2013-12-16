chokidar = require 'chokidar'
minimatch = require 'minimatch'

class Watcher

  constructor: (@roots) ->

  exec: ->
    @roots.compile().once 'done', =>
      chokidar.watch(@roots.root, { ignoreInitial: true, ignored: ignore.bind(@) })
        .on('error', (err) => @roots.emit('error', err))
        .on('change', @roots.compile.bind(@roots))

  # @api private

  ignore = (p) ->
    f = p.replace(@roots.root, '').slice(1)
    @roots.config.ignores.map((i) -> minimatch(f, i, { dot: true })).filter((i)->i).length

module.exports = Watcher
