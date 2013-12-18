should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures/new')
rimraf = require 'rimraf'
mkdirp = require 'mkdirp'
require('./helpers')(should)
test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

Roots = require '../lib'

describe 'new', ->

  it 'should throw if not given a path', ->
    (-> Roots.new()).should.throw

  it 'should create a project with the base tpl, emit all events, and return a roots instance from the callback', (done) ->
    p = path.join(test_path, 'testing')

    events = 0
    increment = -> ++events

    finish = (err) ->
      if err then return done(err)
      events.should.be.above(2)
      rimraf.sync(p)
      Roots.template.remove('base').done((-> done()), done)

    Roots.new(
      path: p
      options: { name: 'foo', description: 'bar' }
      done: (inst) -> inst.should.be.an.instanceof(Roots)
    ).on('done', -> finish())
     .on('error', finish)
     .on('template:base_added', increment)
     .on('template:created', increment)
     .on('deps:installing', increment)
     .on('deps:finished', increment)

  it 'should create a project with another template if provided', (done) ->
    p = path.join(test_path, 'testing')

    Roots.template.add(name: 'foobar', url: test_tpl_path)
      .catch(done)
      .then ->
        Roots.new(path: p, options: { foo: 'bar' }, template: 'foobar').on 'done', ->
          fs.existsSync(path.join(p, 'index.html')).should.be.ok
          rimraf.sync(p)
          Roots.template.remove('foobar').then(-> done())
