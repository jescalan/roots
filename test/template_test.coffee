should = require 'should'
nodefn = require 'when/node/function'
Roots = require '../'
test_tpl_path = 'https://github.com/jenius/sprout-test-template.git'

describe 'template', ->

  it 'should add a new template', (done) ->
    Roots.template.add(name: 'foobar', url: test_tpl_path)
      .then(-> Roots.template.remove('foobar'))
      .done((-> done()), done)

  it 'should list all templates', (done) ->
    Roots.template.add(name: 'foobar', url: test_tpl_path)
      .then(-> Roots.template.list().length.should.be.above(0))
      .then(-> Roots.template.remove('foobar'))
      .done((-> done()), done)
