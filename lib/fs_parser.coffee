fs = require 'fs'
path = require 'path'
W = require 'when'
readdirp = require 'readdirp'
_ = require 'lodash'
minimatch = require 'minimatch'
yaml_parser = require './yaml_parser'

class FSParser

  constructor: (@roots) ->

  parse: ->
    task = new ParseTask(@roots)

    if fs.statSync(@roots.root).isDirectory()
      promise = task.parse_dir(@roots.root)
    else
      promise = task.parse_file(@roots.root)

class ParseTask

  constructor: (@roots) ->
    @ast = { dirs: [], compiled: [], static: [], dynamic: [] }

  parse_dir: (dir) ->
    deferred = W.defer()
    files = []

    readdirp(root: dir)
      .on('end', => deferred.resolve(W.all(files).then(format_dirs.bind(@))))
      .on('error', deferred.reject)
      .on 'data', (f) =>
        if ignored.call(@, f.path) then return
        if f.parentDir.length then @ast.dirs.push(f.parentDir)
        files.push(@parse_file(f.fullPath))

    return deferred.promise

  parse_file: (file) ->
    yaml_parser.detect(file)
      .then((res) =>
        cat = if res then 'dynamic' else if compiled.call(@, file) then 'compiled' else 'static'
        @ast[cat].push(file)
      ).yield(@ast)

  # @api private
  
  format_dirs = ->
    @ast.dirs = _.uniq(@ast.dirs).map((d) => path.join(@roots.config.output_path(), d))
    @ast

  ignored = (f) ->
    @roots.config.ignores.map((i) -> minimatch(f, i, { dot: true })).filter((i) -> i).length

  compiled = (f) ->
    exts = _(@roots.config.compilers).map((i)-> i.extensions).flatten().value()
    _.contains(exts, path.extname(f).slice(1))

module.exports = FSParser

###

What's Going On Here?
---------------------

This class is responsible for analyzing a roots project and sorting each file into a category for processing later. It can be fed a file or a directory, and will produce an object containing arrays for `dirs`, `compiled`, `static`, and `dynamic`, each array containing full paths to the specified file.

You will probably quickly notice that the FSParser class uses a private ParseTask class for most of its logic. This is because while there is only one FSParser per Roots object, the `parse` method is async and it's possible that more than one `parse` could be running at once. Since each `parse` call outputs a shared ast, ast cannot be a property of the FSParser class to prevent possible conflicts between parallel-running `parse` calls, and would have to be passed between each method call to keep it without conflict. But to make this cleaner, we  utilize a private class that is instantiated each `parse` call and can safely share the ast between its methods.

There are only really two methods being called here, `parse_dir` and `parse_file`. Starting with the directory parse, we use readdirp to read through the project directory. When it encounters a file (on 'data' event), a few things happen. First, it checks to make sure the file is not ignored. By using minimatch to test against the file path, we can ensure that full globstar ignores (like in .gitignore) are supported. Next, if the file is nested in a directory, we push that to the ast directories array. Finally, we process the file, and add that task to an array which we resolve using [when.all](https://github.com/cujojs/when/blob/master/docs/api.md#whenall) once all the files have been read. On the way out, one more task goes through `ast.dirs` and formats them correctly, since they don't come out totally right initially.

The `parse_file` function is the logic core for this class. Since dynamic files are processed before normally compiled files because they make locals available in all other views, each file needs to be analyzed to determine whether it contains dynamic content or not. In order to do this as efficiently as possible, only the first three bytes of each file is read asynchrnously as a stream, which is all it takes to determine that the file does or does not contain dynamic content. See `./yaml_parser.coffee` for more details.

###
