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

describe 'write hook', ->

  before (done) ->
    @path = path.join(__dirname, 'fixtures/extensions/write_hook')
    @public = path.join(@path, 'public')
    project = new Roots(@path)
    project.extensions.all.length.should.be.above(2)
    project.compile().on('error', done).on('done', done)

  it 'returning false on write hook should prevent write', ->
    should.not_exist(@public, 'prevent_write.html')

  it 'returning true on write hook should write normally', ->
    should.exist(@public, 'write_normal.html')

  it 'should write one one custom path from write hook', ->
    should.exist(@public, 'override.html')
    should.contain_content(@public, 'override.html', /wow overrides/)

  it 'should write multiple custom paths from write hook', ->
    should.exist(@public, 'multi1.html')
    should.contain_content(@public, 'multi1.html', /clone 1/)
    should.exist(@public, 'multi2.html')
    should.contain_content(@public, 'multi2.html', /clone 2/)
