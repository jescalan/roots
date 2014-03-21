should    = require 'should'
path      = require 'path'
fs        = require 'fs'
run       = require('child_process').exec
W         = require 'when'
nodefn    = require 'when/node'
test_path = path.join(__dirname, 'fixtures')
glob      = require 'glob'
rimraf    = require 'rimraf'

Roots = require '../lib'

# make sure all tests with deps have them installed
before (done) ->
  tasks = []
  for d in glob.sync("#{test_path}/*/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d.replace(test_path,'').replace('.json','')}...".grey
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks).then(-> done())

# remove all test output
after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

describe 'constructor', ->

  it 'fails when given nonexistant path', ->
    (-> project = new Roots('sdfsdfsd')).should.throw

  it 'exposes config and root', ->
    project = new Roots(path.join(test_path, 'compile/basic'))
    project.root.should.be.ok
    project.config.should.be.ok
