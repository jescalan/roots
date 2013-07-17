should = require 'should'
path = require 'path'
roots = require '../../lib/index'
Project = require '../../lib/project'
root = __dirname

project = undefined
config = {}

describe 'class Project', ->
  rootDir = path.join root, '../basic'

  it 'should accept a config object', ->
    project = new Project(rootDir, config)

  it 'should have proper defaults', ->
    project.path('public').should.eql './public' # broken
    project.rootDir.should.not.eql ''

  it 'buildIgnoreFiles() should work', (done) ->
    project.buildIgnoreFiles(->
      project.ignoreFiles.should.eql [
        '/app.coffee'
      ]
      done()
    )

