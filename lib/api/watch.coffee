chokidar = require 'chokidar'
minimatch = require 'minimatch'
_ = require 'lodash'

###*
 * @class Watcher
 * @classdesc Watched a project, recompiles on change
###

class Watcher

  constructor: (@roots) ->

  ###*
   * Compile the project, once done, watch it for further changes.
   * @return {Object} chokidar [https://github.com/paulmillr/chokidar]
     instance
  ###

  exec: ->
    watcher = chokidar.watch(@roots.root, { ignoreInitial: true, ignored: ignore.bind(@) })

    @roots.once 'done', =>
      watcher
        .on('error', (err) => @roots.emit('error', err))
        .on('change', @roots.compile.bind(@roots))

    @roots.compile()

    return _.extend(@roots, { watcher: watcher })

  ###*
   * Given a path, returns true or false depending on whether it should be
     ignored or not.
   * @param {String} p - absolute file path
   * @return {Boolean} whether the file should be ignored or not
   * @private
  ###

  ignore = (p) ->
    f = p.replace(@roots.root, '').slice(1)
    @roots.config.watcher_ignores.map((i) -> minimatch(f, i, { dot: true })).filter((i)->i).length

module.exports = Watcher
