should = require 'should'
path = require 'path'
roots = require '../../lib/index'
Project = require '../../lib/project'
root = __dirname

project = undefined
config = {}

describe 'class Project', ->
  root_dir = path.join root, '../basic'

  it 'should accept a config object', ->
    project = new Project(root_dir, config)

  it 'should have proper defaults', ->
    project.public_dir.should.eql '/public'
    project.root_dir.should.not.eql ''

  it 'build_ignore_files() should work', (done) ->
    project.build_ignore_files(->
      project.ignore_files.should.eql [
        '/app.coffee'
      ]
      done()
    )

