fs       = require 'graceful-fs'
path     = require 'path'
W        = require 'when'
readdirp = require 'readdirp'
_        = require 'lodash'
mm       = require 'micromatch'
pipeline = require 'when/pipeline'
File     = require 'vinyl'

###*
 * @class FS Parser
 * @classdesc Recursively parses the project folder, producing an object
 *            which puts each file into a category for processing.
###

class FSParser

  ###*
   * Creates a new instance of the FSParser class. Sets up instance vars:
   *
   * - root: the project root
   * - config: roots config object
   * - extensions: all extension instances for this compile
   *
   * @param  {Function} roots - instance of the roots base class
  ###

  constructor: (@roots, @extensions) ->
    @root = @roots.root
    @config = @roots.config

  ###*
   * Parses the roots base class' root path, whether file or directory
   * returns an "ast" representing the files categorized by the way they
   * need to be parsed. The ast is an object with the key being the
   * category name and the value being an array of vinyl file instances.
   * It would look something like this (with one 'example' extension):
   *
   * {
   *   compiled: [<File>, <File>],
   *   example: [<File>, <File>, <File>],
   *   static: [<File>]
   * }
   *
   * @return {Object} when.js promise for an ast
  ###

  parse: ->
    @ast = { dirs: [] }

    if fs.statSync(@root).isDirectory()
      parse_dir.call(@, @root)
    else
      parse_file.call(@, @root)

  ###*
   * Parses the root as a directory, reading it recursively, adding
   * all subdirectories to the `dirs` category, and parsing all files
   * with the `parse_file` method below.
   *
   * @private
   *
   * @param  {String} dir - path to a directory
   * @return {Object} 'ast' object, described above
  ###

  parse_dir = (dir) ->
    deferred = W.defer()
    files = []

    readdirp(root: dir, directoryFilter: ['!.git', '!node_modules'])
      .on('end', => deferred.resolve(W.all(files).then(format_dirs.bind(@))))
      .on('error', deferred.reject)
      .on 'data', (f) =>
        if ignored.call(@, f.path) then return
        if f.parentDir.length then @ast.dirs.push(f.fullParentDir)
        file = parse_file.call(@, f.fullPath)
        file.then((-> files.push(file)), deferred.reject)

    return deferred.promise

  ###*
   * Goes through each extension and runs it's `detect` function for the
   * provided file. If it passes, the file is added to that extension's
   * category. The roots default `static` extension runs last and collects any
   * and all files that were not sorted into other categories.
   *
   * Also note the partial application and use of `when/pipeline`. We bind each
   * extension and the file to the `sort` function upfront, and leave only the
   * last parameter to be set, which represents `extract`, discussed below.
   * Pipeline calls each function in an array in order, passing the results of
   * the last function to the next one. The arg provided to pipeline is what
   * goes to the first function in the list. Detailed docs for pipeline found
   * here:
   *
   * https://github.com/cujojs/when/blob/master/docs/api.md#whenpipeline
   *
   * This method also wraps each file in a vinyl wrapper. More info in vinyl:
   * https://github.com/wearefractal/vinyl
   *
   * @private
   *
   * @param  {String} file - path to a file
  ###

  parse_file = (file) ->
    file = new File(base: @root, path: file)
    list = (sort.bind(@, ext, file) for ext in @extensions when ext.fs)

    pipeline(list, false).yield(@ast)

  ###*
   * Given a file and an extension, runs the extension's `detect` function
   * on the file. If it returns false, the file is not added to the extension's
   * category and the function returns. If true, the file is added to the
   * extension's category.
   *
   * After this, if the extension has `extract` set to true, meaning that once
   * a file has been added to it's category, it's not eligable to be added to
   * any other category, it returns `true`. At the top of the sort function,
   * if `true` comes in (meaning a file has been added to a category and
   * extracted), it will skip any detection and continue passing true down the
   * line.
   *
   * The way pipeline works above, the result of one function is passed to the
   * next. So as soon as an extension returns true (aka file is extracted),
   * detections will not be run for any other extension, and therefore it will
   * not be added to any other categories.
   *
   * @private
   *
   * @param  {Function} ext - a roots extension instance
   * @param  {File} file - vinyl wrapper for a file
   * @param  {Boolean} extract - if true, function is skipped
   * @return {Boolean} promise for a boolean, passed as extract to next function
   *
   * @todo handle error if ext.fs.detect doesn't exist
   * @todo handle error if category not found
  ###

  sort = (ext, file, extract) ->
    if extract then return true

    extfs = ext.fs()

    if typeof extfs isnt 'object'
      @roots.bail(125, 'fs function must return an object')

    W.resolve(extfs.detect(file)).then (detected) =>
      if not detected then return false
      cat = extfs.category ? ext.category
      @ast[cat] ?= []
      @ast[cat].push(file) unless _.includes(@ast[cat], file)
      return extfs.extract

  ###*
   * Makes sure there are no duplicate directories and that they all directories
   * are passed through as vinyl-wrapped file objects.
   *
   * @private
   *
   * @return {Object} - modified instance of the `ast`
  ###

  format_dirs = ->
    @ast.dirs = _.uniq(@ast.dirs).map((d) => new File(base: @root, path: d))
    @ast

  ###*
   * Checks a file against the ignored list to see if it should be skipped.
   *
   * @param  {String} f - file path
   * @return {Boolean} whether the file should be ignored or not
  ###

  ignored = (f) ->
    @config.ignores
      .map((i) -> mm.isMatch(f, i, dot: true))
      .filter((i) -> i)
      .length

module.exports = FSParser
