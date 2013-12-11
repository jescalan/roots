fs = require 'fs'
path = require 'path'

module.exports = 

  before: (cb) ->
    fs.open(path.join(@root, 'before.txt'), 'w', cb)

  after: (cb) ->
    fs.open(path.join(@config.output_path(), 'after.txt'), 'w', cb)
