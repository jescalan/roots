should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures')
shell = require 'shelljs'

roots = require '../lib'

describe 'basic', ->

  before ->
    @path = path.join(test_path, 'basic')
    @output = path.join(@path, 'public')

  it 'should compile', (done) ->
    roots.compile(@path)
      .on('error', (err) -> console.error(err))
      .on 'done', =>
        fs.existsSync(@output).should.be.ok
        fs.existsSync(path.join(@output, 'nested')).should.be.ok
        fs.existsSync(path.join(@output, 'nested/double_nested')).should.be.ok
        done()

  after -> shell.rm('-rf', @output)

