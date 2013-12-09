should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures')
run = require('child_process').exec
require('./helpers')(should)

Roots = require '../lib'

describe 'basic', ->

  it 'should compile files in nested directories', (done) ->
    p = path.join(test_path, 'basic')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', =>
        should.exist(output, [
          'index.html',
          'nested',
          'nested/foo.html',
          'nested/double_nested',
          'nested/double_nested/bar.html'
        ])
        done()

  it 'should copy files in nested directories', (done) ->
    p = path.join(test_path, 'copy')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, ['foo.html', 'nested/bar.html', 'nested/whatever.blah'])
        done()

  # remove all test output (this needs to work cross-platform)
  after (done) -> run('rm -rf test/fixtures/**/public', done)
