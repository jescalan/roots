should = require 'should'
path = require 'path'
fs = require 'fs'
run = require('child_process').exec
W = require 'when'
nodefn = require 'when/node/function'

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

# remove all test output (this needs to work cross-platform)
after (done) -> run('rm -rf test/fixtures/**/public', done)

describe 'constructor', ->

  it 'fails when given nonexistant path'
  it 'exposes config and root'
