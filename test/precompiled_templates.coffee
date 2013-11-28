require 'colors'

should  = require 'should'
path    = require 'path'
fs      = require 'fs'
_       = require 'underscore'
shell   = require 'shelljs'
config  = require '../lib/global_config'
run     = require('child_process').exec
root    = __dirname

require('./helpers')(should)

remove = (test_path) ->
  shell.rm('-rf', test_path)

run_in_dir = (dir, cmd, cb) ->
  run("cd \"#{dir}\"; #{path.join(path.relative(dir, __dirname), '../bin/roots')} #{cmd}", cb)

describe 'precompiled templates', ->

  before (done) ->
    @root = path.join(root, 'precompile')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'precompiles templates', ->
    should.exist(@output, '/js/templates.js')
    should.contain_content(@output, 'js/templates.js', /\<p\>hello world\<\/p\>/)

  it 'should compile nested templates', ->
    should.contain_content(@output, 'js/templates.js', /['pluder\/island']/)

  it 'should compile deeply nested templates', ->
    should.contain_content(@output, 'js/templates.js', /['pluder\/spoon\/cay']/)

describe 'precompiled templates empty cases', ->
  it 'should not fail when there is no template folder', (done) ->
    @root = path.join(root, 'precompile')
    @output = path.join(@root, 'public')
    fs.renameSync(path.join(@root, '/templates'), path.join(@root, '/templates_tmp'))
    run_in_dir @root, 'compile --no-compress', =>
      fs.renameSync(path.join(@root, '/templates_tmp'), path.join(@root, '/templates'))
      done()

  it 'should not fail when the templates folder is empty', (done) ->
    @root = path.join(root, 'precompile')
    @output = path.join(@root, 'public')
    fs.renameSync(path.join(@root, '/templates'), path.join(@root, '/templates_tmp'))
    fs.mkdirSync(path.join(@root, '/templates'))
    run_in_dir @root, 'compile --no-compress', =>
      remove(path.join(@root, '/templates'))
      fs.renameSync(path.join(@root, '/templates_tmp'), path.join(@root, '/templates'))
      done()
