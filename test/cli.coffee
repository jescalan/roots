path   = require 'path'
should = require 'should'
cli    = require '../lib/cli'
pkg    = require('../package.json')

test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'cli', ->

  it "'roots --version' should return the version", (done) ->
    cli.once 'data', (data) ->
      pkg.version.should.equal(data)
      done()

    cli.execute({ _: [], v: true, version: true }, pkg)

  it '`roots xxx` should return an error', (done) ->
    cli.once 'err', (data) ->
      data.should.match /command not found/
      done()

    cli.execute(_: ['xxx'])

  it "'roots' should return help", (done) ->
    cli.once 'data', (data) ->
      data.should.match /Roots Usage/
      done()

    cli.execute(_: [])

  it '`roots help` should return help text', (done) ->
    cli.once 'data', (data) ->
      data.should.match /Roots Usage/
      done()

    cli.execute(_: ['help'])

  it '`roots help --quiet` should not log output', (done) ->
    cli.once 'data', (data) -> data.should.not.exist
    setTimeout(done, 250)

    cli.execute({ _: ['help'] }, quiet: true)

  describe 'new', ->

    it '`roots new` should error', (done) ->
      cli.once 'err', (data) -> data.should.not.exist
      setTimeout(done, 250)

      cli.execute(_: ['new'])

    # todo: need a good way to test this/respond to queries
    it '`roots new blah` should not error'

  describe 'compile', ->

    it '`roots compile` should compile a project', (done) ->
      cli.once 'inline', (data) ->
        data.should.eql('compiling... '.grey)
        process.chdir(cwd)
        done()

      cwd = process.cwd()
      process.chdir(path.join(__dirname, 'fixtures/compile/basic'))
      cli.execute(_: ['compile'])

    it '`roots compile /path/etc` should compile a project at a path', (done) ->
      cli.once 'inline', (data) ->
        data.should.eql('compiling... '.grey)
        done()

      cli.execute(_: ['compile', path.join(__dirname, 'fixtures/compile/copy')])

  describe 'watch', ->

    # TODO: need a way to cancel the watch process here
    it.skip '`roots watch` should watch a project', (done) ->
      cli.once 'inline', (data) ->
        data.should.eql('compiling... '.grey)
        process.chdir(cwd)
        done()

      cwd = process.cwd()
      process.chdir(path.join(__dirname, 'fixtures/compile/basic'))
      cli.execute(_: ['watch'])

    it '`roots watch /path/etc` should watch a project at a path'

  describe 'tpl', ->

    it '`roots tpl add name url` should add a template', (done) ->
      cli.once 'data', (data) ->
        data.should.eql("done!".green)
        done()

      cli.execute(_: ['tpl', 'add', 'foo', test_tpl_path])

    it '`roots tpl` should return help', (done) ->
      cli.once 'data', (data) ->
        data.should.match /Roots Templates/
        done()

      cli.execute(_: ['tpl'])

    it '`roots tpl add name` should error', (done) ->
      cli.once 'err', (data) ->
        data.should.exist
        done()

      cli.execute(_: ['tpl', 'add', 'foo'])

    it '`roots tpl list` should list templates', (done) ->
      cli.once 'data', (data) ->
        data.should.match /Templates/
        done()

      cli.execute(_: ['tpl', 'list'])

    it '`roots tpl default` should error', (done) ->
      cli.once 'err', (data) ->
        data.should.exist
        done()

      cli.execute(_: ['tpl', 'default'])

    it '`roots tpl default xxx` should error because no templates installed', (done) ->
      cli.once 'err', (data) ->
        data.should.exist
        done()

      cli.execute(_: ['tpl', 'default', 'xxx'])

    it '`roots tpl remove name` should remove a template', (done) ->
      cli.once 'data', (data) ->
        data.should.eql "template 'foo' removed".green
        done()

      cli.execute(_: ['tpl', 'remove', 'foo'])
