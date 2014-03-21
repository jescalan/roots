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
          'nested/double_nested/bar.html',
          'unicode_land.html',
          'empty.html'
        ])
        should(fs.statSync(path.join(output, "doge.png")).size).equal(fs.statSync(path.join(p, "doge.png")).size)
        should.contain_content(output, 'unicode_land.html', /å sky so hîgh ☆/)
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

  it 'should be able to handle the most Fd filenames ever', (done) ->
    p = path.join(test_path, 'weird_filenames')
    output = path.join(p, 'public')

    new Roots(p).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'foo bar.wow')
        should.exist(output, 'pesta#na.md')
        should.exist(output, 'doge.eats.twerking-cyrus-tm-___cat.png')
        should.exist(output, 'folder.withdot')
        should.exist(output, 'folder.withdot/.dotfile.wow')
        should.exist(output, 'folder.withdot/file.something.other.js')
        should.exist(output, 'folder.withdot/look@mybiceps')
        should.exist(output, 'folder.withdot/manyOf∫chin')
        should.exist(output, 'folder.withdot/manyOf∫chin/er mer .gerd.wat')
        done()

  it 'should work with different environments', (done) ->
    p = path.join(test_path, 'environments')
    output = path.join(p, 'public')

    new Roots(p, { env: 'doge' }).compile()
      .on('error', done)
      .on 'done', ->
        should.exist(output, 'doge_file.html')
        should.not_exist(output, 'dev_file.html')
        done()
