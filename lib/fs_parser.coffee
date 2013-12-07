fs = require 'fs'
path = require 'path'
readdirp = require 'readdirp'
W = require 'when'
_ = require 'lodash'
minimatch = require 'minimatch'
async = require 'async'

yaml_parser = require './yaml_parser'

class FSParser

  constructor: (@root) ->
    @concurrency = 50

  parse: ->
    deferred = W.defer()
    ast = { dirs: [], compiled: [], static: [], dynamic: [] }

    if fs.statSync(@root).isDirectory()
      parse_dir.call(@, ast, deferred)
    else
      parse_file.call(@, ast, deferred)

    return deferred.promise

  # @api private

  parse_dir = (ast, d) ->
    queue = async.queue(((f, cb) -> parse_file.call({ root: f.fullPath }, ast, cb)), @concurrency)

    readdirp(root: @root)
      .on('end', -> if queue.length() < 1 then d.resolve(ast) else queue.drain = -> d.resolve(ast))
      .on('error', d.reject)
      .on 'data', (e) ->
        if ignored(e.path) then return
        if e.parentDir.length then ast.dirs.push(e.parentDir)
        queue.push(e)

  parse_file = (ast, done) ->
    yaml_parser.detect @root, (dynamic) =>
      cat = if dynamic then 'dynamic' else if compiled(@root) then 'compiled' else 'static'
      ast[cat].push(@root)
      done(ast)

  ignored = (f) ->
    config.get().ignores.map((i) -> minimatch(f, i, { dot: true })).filter((i) -> i).length

  compiled = (f) ->
    exts = _(config.get().compilers).map((i)-> i.extensions).flatten().value()
    _.contains(exts, path.extname(f).slice(1))

module.exports = FSParser

# What's Going On Here?
# ---------------------

# This class is responsible for analyzing a roots project and sorting each file
# into a category for processing later. It can be fed a file or a directory, and
# will produce an object containing arrays for `dirs`, `compiled`, `static`, and
# `dynamic`, each array containing [file objects](https://github.com/thlorenz/readdirp#entry-info)
# returned from readdirp.

# The `parse_file` function is the logic core for this class. Since dynamic files
# are processed before normally compiled files because they make locals available
# in all other views, each file needs to be analyzed to determine whether it contains
# dynamic content or not. In order to do this as efficiently as possible, the files are
# read as a stream, which is closed as soon as it can be determined that the file does
# or does not contain dynamic content. See `yaml_parser.coffee` for more details.

# Since the project structure read is async and the operation on each file (described above)
# is also async, there needs to be a way to know when the reading of the project folder has
# ended and the type detection for all files have also ended. We use `async.queue` to handle
# this complex interaction. All file parse operations are added to the queue, and once
# the project structure read completes, if the queue is already empty, it calls back, and if
# not, a listener is attached so that when the queue does empty, it calls back then.

# This class also handles all the ignores, by simply using minimatch to test against
# the file path. Because of this, full globstar ignores a la gitignore are supported.
