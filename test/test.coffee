should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures')
shell = require 'shelljs'
require('./helpers')(should)

roots = require '../lib'

describe 'basic', ->

  before ->
    @path = path.join(test_path, 'basic')
    @output = path.join(@path, 'public')

  it 'should compile', (done) ->
    roots.compile(@path)
      .on('error', (err) -> console.error(err))
      .on 'done', =>
        should.exist(@output, '')
        should.exist(@output, 'index.html')
        should.exist(@output, 'nested')
        should.exist(@output, 'nested/foo.html')
        should.exist(@output, 'nested/double_nested')
        should.exist(@output, 'nested/double_nested/bar.html')
        done()

  after -> shell.rm('-rf', @output)

