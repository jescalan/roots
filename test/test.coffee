should = require 'should'
path = require 'path'
fs = require 'fs'
run = require('child_process').exec
W = require 'when'
nodefn = require 'when/node/function'
test_path = path.join(__dirname, 'fixtures')

Roots = require '../lib'

# make sure all tests with deps have them installed
before (done) ->
  tasks = []
  for d in fs.readdirSync(test_path)
    p = path.join(__dirname, 'fixtures', d)
    if not fs.existsSync(path.join(p, 'package.json')) then continue
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d}"
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks, -> done())

# remove all test output (this needs to work cross-platform)
after (done) -> run('rm -rf test/fixtures/**/public', done)

describe 'constructor', ->

  it 'fails when given nonexistant path', ->
    (-> project = new Roots('sdfsdfsd')).should.throw

  it 'exposes config and root', ->
    project = new Roots(path.join(test_path, 'compile/basic'))
    project.root.should.be.ok
    project.config.should.be.ok
