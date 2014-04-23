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
    @project = new Roots(path.join(base_path, 'extensions/basic'))
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
    path.join(@public, 'prevent_write.html').should.not.be.a.path()

  it 'returning true on write hook should write normally', ->
    path.join(@public, 'write_normal.html').should.be.a.file()

  it 'should write one one custom path from write hook', ->
    path.join(@public, 'override.html').should.be.a.file()
    path.join(@public, 'override.html').should.have.content('wow overrides')

  it 'should write multiple custom paths from write hook', ->
    path.join(@public, 'multi1.html').should.be.a.file()
    path.join(@public, 'multi1.html').should.have.content('clone 1')
    path.join(@public, 'multi2.html').should.be.a.file()
    path.join(@public, 'multi2.html').should.have.content('clone 2')
    path.join(@public, 'subdir/multi3.html').should.be.a.file()
    path.join(@public, 'subdir/multi3.html').should.have.content('clone 3')

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

# All of these function should be throwing -- none should be returning an error
# through the promise handler. When there's an extension error, the flow needs
# to be immediately stopped.

describe 'extension failures', ->

  before ->
    @path = path.join(__dirname, 'fixtures/extensions/failures')

  it 'should bail when the extension does not return a class/function', ->
    (=> new Roots(path.join(@path, 'case1')))
      .should.throw('Extension must return a function/class')

  # this should not throw
  it 'should bail when fs is defined but not a function', ->
    project = new Roots(path.join(@path, 'case2'))
    (-> project.compile()).should.throw('The fs property must be a function')

  it 'should bail when fs is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case3'))

    project.on 'error', (err) ->
      err.toString().should.equal('Malformed Extension: fs function must return an object')
      done()

    project.compile()

  it 'should bail when fs is used with no category', (done) ->
    project = new Roots(path.join(@path, 'case4'))

    project.on 'error', (err) ->
      err.toString().should.equal('Malformed Extension: fs hooks defined with no category')
      done()

    project.compile()

  # this should not throw
  it 'should bail when compile_hooks is defined but not a function', ->
    project = new Roots(path.join(@path, 'case5'))
    (-> project.compile()).should.throw('The compile_hooks property must be a function')

  it 'should bail when compile_hooks is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case6'))

    project.on 'error', (err) ->
      err.toString().should.equal('Malformed Extension: compile_hooks should return an object')
      done()

    project.compile()

  it 'should bail when compile_hooks returned object keys are not functions'

  # this should not throw
  it 'should bail when category_hooks is defined but not a function', ->
    project = new Roots(path.join(@path, 'case7'))
    (-> project.compile()).should.throw('The category_hooks property must be a function')

  it 'should bail when category_hooks is a function but doesnt return an object', (done) ->
    project = new Roots(path.join(@path, 'case8'))

    project.on 'error', (err) ->
      err.toString().should.equal('Malformed Extension: category_hooks should return an object')
      done()

    project.compile()

  it 'should bail if write hook returns anything other than an array, object, or boolean', (done) ->
    project = new Roots(path.join(@path, 'case9'))

    project.on 'error', (err) ->
      err.toString().should.equal('Malformed Write Hook Output: invalid return from write_hook')
      done()

    project.compile()

  it "should bail if an extension's constructor throws an error", ->
    project = new Roots(path.join(@path, 'case10'))
    (-> project.compile()).should.throw('wow')

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
        path.join(@public, 'test.html').should.be.a.file()
        done()

    @project.compile()
