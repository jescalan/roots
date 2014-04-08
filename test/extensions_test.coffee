should = require 'should'
path   = require 'path'
fs     = require 'fs'
Roots  = require '../lib'

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
    @project
      .on('error', done)
      .on('before_file', => @before_file = true)
      .on('after_file', => @after_file = true)
      .on('before_pass', => @before_pass = true)
      .on('after_pass', => @after_pass = true)
      .on('write', => @write = true)
      .on('after_category', => @after_category = true)
      .on('done', -> done())

    @project.compile()

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
    project.on('error', done).on('done', -> done())
    project.compile()

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

describe 'categories', ->

  before (done) ->
    @file = []
    @category = []

    @path = path.join(__dirname, 'fixtures/extensions/category_scope')
    @public = path.join(@path, 'public')
    project = new Roots(@path)

    project
      .on('error', done)
      .on('after_file', (r) => @file.push(r))
      .on('after_category', (r) => @category.push(r))
      .on('done', -> done())

    project.compile()

  it 'should scope all hooks to an extension-bound category property', ->
    @file.indexOf('[1] active').should.be.above(-1)
    @category.indexOf('[1] scope_test').should.be.above(-1)

  it 'should allow individual hook blocks to override the category', ->
    @file.indexOf('[2] scope_override').should.be.above(-1)
    @file.indexOf('[3] failed_override').should.be.below(0)
    @category.indexOf('[2] scope_override').should.be.above(-1)
    @category.indexOf('[2] whack').should.be.below(0)

  it 'should run hooks on every category if no category is provided', ->
    @file.indexOf('[5] active').should.be.above(-1)
    @file.indexOf('[5] passive').should.be.above(-1)
    @file.indexOf('[5] failed_override').should.be.above(-1)
    @file.indexOf('[5] hook_level').should.be.above(-1)
    @file.indexOf('[5] scope_override').should.be.above(-1)
    @category.indexOf('[5] compiled').should.be.above(-1)
    @category.indexOf('[5] static').should.be.above(-1)
    @category.indexOf('[5] not_overridden').should.be.above(-1)
    @category.indexOf('[5] hook_level').should.be.above(-1)
    @category.indexOf('[5] scope_override').should.be.above(-1)
    @category.indexOf('[5] scope_test').should.be.above(-1)

  it 'should still run correctly with only hook-level categories defined', ->
    @file.indexOf('[4] hook_level').should.be.above(-1)
    @category.indexOf('[4] hook_level').should.be.above(-1)

# Some of these are thrown as errors, others are reported through roots'
# "on error" handler. This is just because of their placement within the
# code. While I would like to make this more consistent the priority for
# now is that all the errors are working and have clear messages.

describe 'extension failures', ->

  before ->
    @path = path.join(__dirname, 'fixtures/extensions/failures')

  # @todo: should these be throwing?
  it 'should bail when the extension does not return a class/function', ->
    (-> (new Roots(path.join(@path, 'case1'))).compile()).should.throw()

  # @todo: should these be throwing?
  it 'should bail when fs is defined but not a function', ->
    (-> (new Roots(path.join(@path, 'case2'))).compile()).should.throw()

  it 'should bail when fs is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case3'))
    project.on('error', -> done())
    project.compile()

  it 'should bail when fs is used with no category', (done) ->
    project = new Roots(path.join(@path, 'case4'))
    project.on('error', -> done())
    project.compile()

  # @todo: should these be throwing?
  it 'should bail when compile_hooks is defined but not a function', ->
    (-> (new Roots(path.join(@path, 'case5'))).compile()).should.throw()

  it 'should bail when compile_hooks is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case6'))
    project.on('error', -> done())
    project.compile()

  it 'should bail when compile_hooks returned object keys are not functions'

  # @todo: should these be throwing?
  it 'should bail when category_hooks is defined but not a function', ->
    (-> (new Roots(path.join(@path, 'case7'))).compile()).should.throw()

  it 'should bail when category_hooks is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case8'))
    project.on('error', -> done())
    project.compile()

  # TODO: this error needs slightly better feedback
  it 'should bail if write hook returns anything other than an array, object, or boolean', (done) ->
    project = new Roots(path.join(@path, 'case9'))
    project.on('error', -> done())
    project.compile()

  # @todo: should these be throwing?
  it "should bail if an extension's constructor throws an error", ->
    (-> (new Roots(path.join(@path, 'case10'))).compile()).should.throw()

  it 'should bail when fs.detect is not a function'
  it 'should bail when category_hooks returned object keys are not functions'

describe 'setup-function', ->

  before ->
    p = path.join(__dirname, 'fixtures/extensions/setup')
    @project = new Roots(p)
    @public = path.join(p, 'public')

  it 'works', (done) ->
    @project
      .on('error', done)
      .on 'test', (v) =>
        v.should.equal('value')
        fs.existsSync(path.join(@public, 'test.html')).should.be.ok
        done()

    @project.compile()
