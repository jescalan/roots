fs = require 'fs'
path = require 'path'

module.exports =

  before: (roots, cb) ->
    fs.open(path.join(roots.root, 'before.txt'), 'w', cb)

  after: (roots, cb) ->
    fs.open(path.join(roots.config.output_path(), 'after.txt'), 'w', cb)
