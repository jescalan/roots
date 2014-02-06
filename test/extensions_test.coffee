should = require 'should'
path = require 'path'
Roots = require '../lib'

describe 'extensions', ->

  it 'should register extensions', ->
    project = new Roots(path.join(__dirname, 'fixtures/compile/basic'))
    ext = project.extensions
    ext.register({ name: 'foo' })
    ext.all.length.should.be.above(0)

  it 'should register extensions at a specified index', ->
    project = new Roots(path.join(__dirname, 'fixtures/compile/basic'))
    ext = project.extensions
    ext.register({ name: 'foo' })
    ext.register({ name: 'bar' })
    ext.all.length.should.be.above(3)
    ext.register({ name: 'baz' }, 0)
    ext.all[0].name.should.eql('baz')

  it 'should remove extensions by name', ->
    project = new Roots(path.join(__dirname, 'fixtures/compile/basic'))
    ext = project.extensions
    ext.register({ name: 'foo' })
    ext.all.length.should.be.above(2)
    ext.remove('foo')
    ext.all.length.should.not.be.above(2)

describe 'extension hooks', ->

  before (done) ->
    project = new Roots(path.join(__dirname, 'fixtures/extensions/basic'))
    project.extensions.all.length.should.be.above(2)
    project.compile()
      .on('error', done)
      .on('done', done)

  it 'before_file hook should work'
  it 'after_file hook should work'
  it 'returning false on after_file should prevent write'
  it 'before_pass hook should work'
  it 'after_pass hook should work'
  it 'write hook should work'
  it 'returning false on write hook should prevent write'
  it 'should write one or more custom paths from write hook'
  it 'after category hook should work'
