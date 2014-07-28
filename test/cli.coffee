rimraf       = require 'rimraf'
mockery      = require 'mockery'
CLI          = require '../lib/cli'
pkg          = require('../package.json')
EventEmitter = require('events').EventEmitter

cli = new CLI(debug: true)
test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'cli', ->

  before -> mockery.enable(warnOnUnregistered: false)
  after -> mockery.disable()

  it 'should throw if no arguments are provided', ->
    (-> cli.run([])).should.throw()

  it 'should throw if a nonexistant command is run', ->
    (-> cli.run('xxx')).should.throw()

  it 'should not error when constructed without debug', ->
    (-> new CLI).should.not.throw()

  it 'should correctly log extension errors', (done) ->
    broken_ext_path = path.join(base_path, 'extensions/failures/case1')

    cb = (err) ->
      err.should.match(/Extension must return a function\/class/)
      cli.removeListener('err', cb)
      done()

    cli.on('err', cb)

    cli.run("compile #{broken_ext_path}")

  it 'should correctly log other thrown errors', (done) ->
    stub = sinon.stub(Roots.prototype, 'compile').returns([])
    mockery.registerMock('../../lib', stub)

    cb = (err) ->
      err.toString().should.equal("TypeError: Object  has no method 'then'")
      cli.removeListener('err', cb)
      stub.restore()
      mockery.deregisterAll()
      done()

    cli.on('err', cb)
    cli.run('compile')

  describe 'new', ->

    # TODO: need to generate an error here somehow

    before ->
      # TODO: we need this to emit progress events for full coverage
      @stub = sinon.stub(Roots, 'new').returns(W.resolve({ root: 'test' }))
      mockery.registerMock('../../lib', Roots)

    after ->
      @stub.restore()
      mockery.deregisterAll()

    it 'should throw with no args passed', ->
      (-> cli.run('new')).should.throw()

    it 'should successfully execute new when a path is provided', (done) ->
      spy = sinon.spy()

      cli.on('success', spy)
      cli.on('info', spy)

      cli.run([ 'new', 'blarg', '-o', 'name: blarg, description: sdfdf' ])
        .done =>
          @stub.should.have.been.calledOnce
          spy.should.have.been.calledThrice
          spy.should.have.been.calledWith('project initialized at test')
          spy.should.have.been.calledWith('using template: roots-base')
          spy.should.have.been.calledWith('done!')
          cli.removeListener('success', spy)
          cli.removeListener('info', spy)
          done()
        , done

    it 'should create a project with a custom template', (done) ->
      spy = sinon.spy()

      cli.on('info', spy)

      cli.run("new blarg -t foobar")
        .done ->
          spy.should.have.been.calledWith('using template: foobar')
          cli.removeListener('info', spy)
          done()
        , done

    it 'should handle errors correctly', ->
      @stub.restore()
      @stub = sinon.stub(Roots, 'new').returns(W.reject())

      cli.run('new blarg').should.be.rejected

    # TODO: need a way to test the live prompts

  describe 'compile', ->

    before ->
      @stub = sinon.stub(Roots.prototype, 'compile').returns(W.resolve())
      mockery.registerMock('../../lib', Roots)

    after ->
      @stub.restore()
      mockery.deregisterAll()

    it 'should compile a project', (done) ->
      spy = sinon.spy()

      cli.on('inline', spy)
      cli.on('data', spy)

      cwd = process.cwd()
      process.chdir(path.join(__dirname, 'fixtures/compile/basic'))

      cli.run('compile')
        .done ->
          spy.should.have.been.calledTwice
          spy.should.have.been.calledWith('compiling... '.grey)
          spy.should.have.been.calledWith('done!'.green)
          process.chdir(cwd)
          cli.removeListener('inline', spy)
          cli.removeListener('data', spy)
          done()
        , done

    it 'should compile a project at a given path', (done) ->
      spy = sinon.spy()

      cli.on('inline', spy)
      cli.on('data', spy)

      cli.run("compile #{path.join(__dirname, 'fixtures/compile/basic')}")
        .done ->
          spy.should.have.been.calledTwice
          spy.should.have.been.calledWith('compiling... '.grey)
          spy.should.have.been.calledWith('done!'.green)
          cli.removeListener('inline', spy)
          cli.removeListener('data', spy)
          done()
        , done

    it 'should handle errors correctly', ->
      @stub.restore()
      @stub = sinon.stub(Roots.prototype, 'compile').returns(W.reject())

      cli.run('compile').should.be.rejected

  describe 'watch', ->

    before ->
      @stub = sinon.stub(Roots.prototype, 'watch').returns(W.resolve())
      mockery.registerMock('../../lib', Roots)

    after ->
      @stub.restore()
      mockery.deregisterAll()

    it 'should watch a project', (done) ->
      spy = sinon.spy()

      cli.on('inline', spy)
      cli.on('data', spy)
      cli.on('err', spy)

      cli.run("watch #{path.join(__dirname, 'fixtures/compile/basic')} --no-open")
        .then (obj) ->
          obj.project.emit('start')
          spy.should.have.been.calledOnce
          obj.project.emit('done')
          spy.should.have.been.calledTwice
          obj.project.emit('error')
          spy.should.have.been.calledThrice
          cli.removeListener('inline', spy)
          cli.removeListener('data', spy)
          cli.removeListener('err', spy)
          obj.server.close(done)

    it 'should error when trying to compile invalid code'

  describe 'clean', ->

    it 'should remove the output folder', (done) ->
      spy = sinon.spy()

      cli.on('success', spy)

      cli.run('clean test').then ->
        spy.should.have.been.calledOnce
        spy.should.have.been.calledWith('output removed')
        cli.removeListener('success', spy)
        done()

  describe 'tpl', ->

    it 'should error without arguments', ->
      (-> cli.run('tpl')).should.throw()

    describe 'add', ->

      before ->
        @stub = sinon.stub(Roots.template, 'add').returns(W.resolve())
        mockery.registerMock('../../../lib', Roots)

      after ->
        @stub.restore()
        mockery.deregisterAll()

      it 'should error without a name', ->
        (-> cli.run('tpl add')).should.throw()

      it 'should succeed with a name', (done) ->
        spy = sinon.spy()

        cli.on('success', spy)

        cli.run('tpl add foo').then ->
          spy.should.have.been.calledOnce
          cli.removeListener('success', spy)
          done()

      it 'should succeed with a name and url', (done) ->
        spy = sinon.spy()

        cli.on('success', spy)

        cli.run('tpl add foo bar').then ->
          spy.should.have.been.calledOnce
          cli.removeListener('success', spy)
          done()

      it 'should handle errors correctly', ->
        @stub.restore()
        @stub = sinon.stub(Roots.template, 'add').returns(W.reject())
        cli.run('tpl add foo').should.be.rejected

    describe 'list', ->

      it 'should list all templates', (done) ->

        cli.on 'data', (data) ->
          data.should.match /Templates/
          done()

        cli.run('tpl list')

    describe 'default', ->

      it 'should error without a name', ->
        (-> cli.run('tpl default')).should.throw()

      it 'should error with non-present template name', (done) ->
        spy = sinon.spy()

        cli.on('err', spy)

        cli.run('tpl default wow').catch ->
          spy.should.have.been.calledOnce
          cli.removeListener('err', spy)
          done()

    describe 'remove', ->

      before ->
        @stub = sinon.stub(Roots.template, 'remove').returns(W.resolve())
        mockery.registerMock('../../../lib', Roots)

      after ->
        @stub.restore()
        mockery.deregisterAll()

      it 'should error without a name', ->
        (-> cli.run('tpl remove')).should.throw()

      it 'should succeed with a name', (done) ->
        spy = sinon.spy()

        cli.on('success', spy)

        cli.run('tpl remove wow').then ->
          spy.should.have.been.calledOnce
          cli.removeListener('success', spy)
          done()

      it 'should handle errors correctly', ->
        @stub.restore()
        @stub = sinon.stub(Roots.template, 'remove').returns(W.reject())
        cli.run('tpl remove foo').should.be.rejected

  describe 'deploy', ->

    before ->
      @stub = sinon.stub Roots.prototype, 'deploy', (args) ->
        d = W.defer()
        process.nextTick ->
          d.notify({ shenanigans: 'very yes' })
          d.notify('wow deploying')
          d.resolve(deployer_name: 'foo')
        return d.promise
      mockery.registerMock('../../lib', Roots)

    after ->
      @stub.restore()
      mockery.deregisterAll()

    it 'should deploy a project', ->
      spy = sinon.spy()
      p = path.join(__dirname, 'fixtures/deploy/shipfile')

      cli.on('info', spy)

      cli.run("deploy #{p}")
        .tap ->
          spy.should.have.been.calledOnce
          cli.removeListener('info', spy)
        .should.be.fulfilled

    it 'should emit an error if the project fails to deploy'
    it 'should emit the url if a url is provided from the output'
