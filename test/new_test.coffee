should = require 'should'
path = require 'path'
fs = require 'fs'
test_path = path.join(__dirname, 'fixtures/new')
rimraf = require 'rimraf'
mkdirp = require 'mkdirp'
require('./helpers')(should)

Roots = require '../lib'

describe 'new', ->

  it 'should throw if not given a path', ->
    (-> Roots.new()).should.throw

  it 'should create a project with the base template, emit all events, and return a roots instance from the callback', (done) ->
    p = path.join(test_path, 'testing')

    events = 0
    increment = -> ++events

    finish = (err) ->
      events.should.be.above(2)
      rimraf.sync(p)
      # roots.template.remove('sprout', -> done(err))
      done(err)

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

  it 'should create a project with another template if provided'
    # this needs to add the template, create, then remove it
    # depends on the roots template commands
