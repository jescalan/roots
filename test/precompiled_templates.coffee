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
