rimraf        = require 'rimraf'
_             = require 'lodash'
nodefn        = require 'when/node'
test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'
new_path      = path.join(base_path, 'new/testing')

describe 'new', ->

  before (done) ->
    Roots.template.add(name: 'test', uri: test_tpl_path)
      .then -> Roots.template.default(name: 'test')
      .then -> done()

  beforeEach (done) ->
    rimraf.sync(new_path, done())

  it 'should reject if not given a path', ->
    Roots.new().should.be.rejected

  it 'should create a project', (done) ->
    spy = sinon.spy()
    Roots.new
      path: new_path
      overrides: { foo: 'love it' }
    .progress(spy)
    .catch(done)
    .done (proj) ->
      proj.root.should.exist
      spy.should.have.callCount(1)
      spy.should.have.been.calledWith('project created')
      rimraf(new_path, done)

  it 'should create a project with another template if provided', (done) ->
    Roots.template.add(name: 'foobar', uri: test_tpl_path)
      .then ->
        overrides = { foo: 'hate it' }
        Roots.new(path: new_path, overrides: overrides, template: 'foobar')
      .then -> util.file.exists('new/testing/index.html').should.be.true
      .then ->
        Roots.template.remove(name: 'foobar')
        nodefn.call(rimraf, new_path)
      .done(done.bind(null, null), done)
