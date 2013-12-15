should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures/new')
require('./helpers')(should)

Roots = require '../lib'

describe 'new', ->

  it 'should append files to an existant folder if passed'
  it 'should create a project with the base template by default'
  it 'should create a project with another template if provided'
  it 'should emit all events correctly'
  it 'should return a roots instance from the done callback'
