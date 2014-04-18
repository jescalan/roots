rimraf       = require 'rimraf'
mockery      = require 'mockery'
cli          = new (require '../lib/cli')(debug: true)
pkg          = require('../package.json')
EventEmitter = require('events').EventEmitter

test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'cli', ->

  before -> mockery.enable(warnOnUnregistered: false)
  after -> mockery.disable()

  it 'should throw if no arguments are provided', ->
    (-> cli.run([])).should.throw()

  it 'should throw if a nonexistant command is run', ->
    (-> cli.run('xxx')).should.throw()

  describe 'new', ->

    before ->
      @stub = sinon.stub(Roots, 'new').returns(W.resolve({ root: 'test' }))
      mockery.registerMock('../../index', Roots)

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
          spy.should.have.been.calledWith('done!')
          spy.should.have.been.calledWith('project initialized at test')
          spy.should.have.been.calledWith('using template: roots-base')
          cli.removeListener('success', spy)
          cli.removeListener('info', spy)
          done()
        , done

    it 'should create a project with a custom template', (done) ->
      spy = sinon.spy()

      cli.on('info', spy)

      cli.run("new blarg -t foobar")
        .done =>
          spy.should.have.been.calledWith('using template: foobar')
          cli.removeListener('info', spy)
          done()
        , done

    # TODO: need a way to test the live prompts

  describe 'compile', ->

    before ->
      @stub = sinon.stub(Roots.prototype, 'compile').returns(W.resolve())
      mockery.registerMock('../../index', Roots)

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

  describe 'watch', ->

    before ->
      @stub = sinon.stub(Roots.prototype, 'watch').returns(new EventEmitter)
      mockery.registerMock('../../index', Roots)

    after ->
      @stub.restore()
      mockery.deregisterAll()

    it 'should watch a project', (done) ->
      spy = sinon.spy()

      cli.on('inline', spy)
      cli.on('data', spy)

      cwd = process.cwd()
      process.chdir(path.join(__dirname, 'fixtures/compile/basic'))
      {server, watcher} = cli.run('watch --no-open')
      spy.should.have.been.calledOnce
      watcher.emit('done')
      spy.should.have.been.calledTwice
      watcher.emit('start')
      spy.should.have.been.calledThrice
      # TODO: browser response needs testing here as well
      process.chdir(cwd)
      cli.removeListener('inline', spy)
      cli.removeListener('data', spy)
      done()

  describe 'clean', ->

    it 'should remove the output folder', ->
      spy = sinon.spy()

      cli.on('success', spy)

      cli.run('clean test')

      spy.should.have.been.calledOnce
      spy.should.have.been.calledWith('output removed')
      cli.removeListener('inline', spy)
      cli.removeListener('data', spy)

  describe 'tpl', ->

    it 'should error without arguments', ->
      (-> cli.run('tpl')).should.throw()

    describe 'add', ->

      before ->
        @stub = sinon.stub(Roots.template, 'add').returns(W.resolve())
        mockery.registerMock('../../../index', Roots)

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

    describe 'list', ->

      it 'should list all templates', (done) ->

        cli.on 'data', (data) ->
          data.should.match /Templates/
          done()

        cli.run('tpl list')

    describe 'default', ->

      before ->
        @stub = sinon.stub(Roots.template, 'default').returns(W.resolve())
        mockery.registerMock('../../../index', Roots)

      after ->
        @stub.restore()
        mockery.deregisterAll()

      it 'should error without a name', ->
        (-> cli.run('tpl default')).should.throw()

      it 'should succeed with a name', (done) ->
        spy = sinon.spy()

        cli.on('success', spy)

        cli.run('tpl default wow').then ->
          spy.should.have.been.calledOnce
          cli.removeListener('success', spy)
          done()

    describe 'remove', ->

      before ->
        @stub = sinon.stub(Roots.template, 'remove').returns(W.resolve())
        mockery.registerMock('../../../index', Roots)

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
