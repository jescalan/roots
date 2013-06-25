should = require 'should'
Project = require('../../lib/project')

describe 'class Project', ->
  it 'should have proper defaults', ->
    test_project = new Project()
    test_project.output_folder.should.eql 'public'

  it 'build_ignore_files() should work', ->
    test_project = new Project()
    test_project.build_ignore_files()
    test_project

  it 'should accept a config object', ->
    config = {}
    test_project = new Project()
