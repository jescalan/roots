should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures')
run = require('child_process').exec
W = require 'when'
nodefn = require 'when/node/function'
require('./helpers')(should)

Roots = require '../lib'

# make sure all tests with deps have them installed
before (done) ->
  tasks = []
  for d in fs.readdirSync(path.join(__dirname, 'fixtures'))
    p = path.join(__dirname, 'fixtures', d)
    if not fs.existsSync(path.join(p, 'package.json')) then continue
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d}"
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks, -> done())

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

  # remove all test output (this needs to work cross-platform)
  after (done) -> run('rm -rf test/fixtures/**/public', done)
