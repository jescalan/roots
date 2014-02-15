should = require 'should'
path = require 'path'
Roots = require '../lib'

describe 'extensions', ->

  it 'should register extensions', ->
    project = new Roots(path.join(__dirname, 'fixtures/compile/basic'))
    ext = project.extensions
    ext.register(-> { name: 'foo' })
    ext.all.length.should.be.above(0)

  it 'should register extensions at a specified index', ->
    project = new Roots(path.join(__dirname, 'fixtures/compile/basic'))
    ext = project.extensions
    ext.register(-> { name: 'foo' })
    ext.register(-> { name: 'bar' })
    ext.all.length.should.be.above(3)
    ext.register((-> { name: 'baz' }), 0)
    ext.all[0]().name.should.eql('baz')

describe 'extension hooks', ->

  before (done) ->
    @project = new Roots(path.join(__dirname, 'fixtures/extensions/basic'))
    @project.extensions.all.length.should.be.above(2)
    @project.compile()
      .on('error', done)
      .on('before_file', => @before_file = true)
      .on('after_file', => @after_file = true)
      .on('before_pass', => @before_pass = true)
      .on('after_pass', => @after_pass = true)
      .on('write', => @write = true)
      .on('after_category', => @after_category = true)
      .on('done', done)

  it 'before_file hook should work', ->
    @before_file.should.be.ok

  it 'after_file hook should work', ->
    @after_file.should.be.ok

  it 'before_pass hook should work', ->
    @before_pass.should.be.ok

  it 'after_pass hook should work', ->
    @after_pass.should.be.ok

  it 'write hook should work', ->
    @write.should.be.ok

  it 'after category hook should work', ->
    @after_category.should.be.ok

  it 'returning false on after_file should prevent write'
  it 'returning false on write hook should prevent write'
  it 'returning true on write hook should write normally'
  it 'should write one or more custom paths from write hook'
