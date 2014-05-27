chokidar  = require 'chokidar'
minimatch = require 'minimatch'
_         = require 'lodash'

###*
 * @class Watcher
 * @classdesc Watched a project, recompiles on change
###

class Watcher

  constructor: (@roots) ->
    @watcher = chokidar.watch @roots.root,
      ignoreInitial: true
      ignored: ignore.bind(@)

  ###*
   * Compile the project, once done, watch it for further changes.
   *
   * @return {Promise} promise that the project has compiled and is watched
  ###

  exec: ->
    @roots.compile().finally =>
      @watcher
        .on('error', (err) => @roots.emit('error', err))
        .on('change', @roots.compile.bind(@roots))
    .yield(@watcher)

  ###*
   * Given a path, returns true or false depending on whether it should be
   * ignored or not.
   *
   * @private
   *
   * @param  {String} p - absolute file path
   * @return {Boolean} whether the file should be ignored or not
  ###

  ignore = (p) ->
    f = p.replace(@roots.root, '').slice(1)
    @roots.config.watcher_ignores
      .map (i) -> minimatch(f, i, { dot: true })
      .filter (i) -> i
      .length

module.exports = Watcher
