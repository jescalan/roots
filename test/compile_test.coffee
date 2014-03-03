should = require 'should'
fs = require 'fs'
path = require 'path'
run = require('child_process').exec
W = require 'when'
nodefn = require 'when/node/function'
test_path = path.join(__dirname, 'fixtures/compile')
require('./helpers')(should)

Roots = require '../lib'

describe 'compile', ->

  it 'should compile files in nested directories', (done) ->
    p = path.join(test_path, 'basic')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', =>
        should.exist(output, [
          'index.html',
          'LECHUCK_ALE',
          'nested',
          'nested/foo.html',
          'nested/double_nested',
          'nested/double_nested/bar.html'
        ])
        should(fs.statSync(path.join(output, "doge.png")).size).equal(fs.statSync(path.join(p, "doge.png")).size)
        done()

  it 'should copy files in nested directories', (done) ->
    p = path.join(test_path, 'copy')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, ['foo.html', 'nested/bar.html', 'nested/whatever.blah'])
        done()

  it 'should load a simple app config', (done) ->
    p = path.join(test_path, 'simple_config')
    output = path.join(p, 'foobar')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'tests.html')
        run("rm -rf #{output}", done)

  it 'should ignore specified files', (done) ->
    p = path.join(test_path, 'ignores')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.not_exist(output, ['ignoreme.html', 'foo'])
        should.exist(output, 'nested_ignore.html')
        done()

  it 'should dump specified dirs', (done) ->
    p = path.join(test_path, 'dump_dirs')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, ['index.html', 'css/foo.css'])
        should.not_exist(output, ['views', 'assets'])
        done()

  it 'should accept custom compiler options', (done) ->
    p = path.join(test_path, 'compiler_options')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'index.html')
        should.match_file(output, 'index.html', 'index_expected.html')
        done()

  it 'should use locals', (done) ->
    p = path.join(test_path, 'locals')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'index.html')
        should.match_file(output, 'index.html', 'index_expected.html')
        done()

  it 'should run before and after hooks', (done) ->
    p = path.join(test_path, 'hooks')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'before.txt')
        should.exist(output, 'after.txt')
        run("rm -rf #{path.join(p, 'before.txt')}", done)

  it 'should correctly handle multipass compiles', (done) ->
    p = path.join(test_path, 'multipass')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'foo.html')
        should.contain_content(output, 'foo.html', /<p>wow<\/p>/)
        should.exist(output, 'bar.html')
        should.contain_content(output, 'bar.html', /<p>wow<\/p>/)
        should.exist(output, 'baz.html')
        should.contain_content(output, 'baz.html', /<p>so compile<\/p>/)
        should.exist(output, 'quux.html')
        should.contain_content(output, 'quux.html', /<p>so compile<\/p>/)
        done()
