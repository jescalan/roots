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

  it 'should integrate an extension with the compile pipeline', (done) ->
    project = new Roots(path.join(__dirname, 'fixtures/extensions/basic'))
    project.extensions.all.length.should.be.above(2)
    project.compile()
      .on('error', done)
      .on('done', done)

