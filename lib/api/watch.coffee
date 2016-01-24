chokidar = require 'chokidar'
mm       = require 'micromatch'
_        = require 'lodash'

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
    __track('api', { name: 'watch' })

    @roots.compile().finally =>
      @watcher
        .on('error', (err) => @roots.emit('error', err))
        .on('change', (file) => @roots.compile(fileChanged: file))
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
      .map (i) -> mm.isMatch(f, i, { dot: true })
      .filter (i) -> i
      .length

module.exports = Watcher
