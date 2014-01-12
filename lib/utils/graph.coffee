_                = require 'underscore'
path             = require 'path'
files            = {}
findit           = require 'findit'
minimatch        = require 'minimatch'
jadeGraph        = require('jade-graph').getDependencies
supportedFormats = ['jade']

module.exports = (basedir) ->
  finder = findit(basedir, {})

  finder.on 'file', (_path) ->
    if canBeGraphed(_path)
      files[_path] = jadeGraph(_path)

canBeGraphed = (_path) ->
  canBe = false
  for extension in supportedFormats
    if minimatch(path.basename(_path), "*.#{extension}")
      canBe = true
  canBe


module.exports.getGraph = (file) ->
  return false unless canBeGraphed(file.absolutePath)

  _.compact(
    _.map(files, (f, p) ->
      if ~f.indexOf(file.absolutePath)
        return p
      false
    )
  )
