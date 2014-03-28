should = require 'should'
Roots = require '../'

describe 'cli', ->

  it '`roots -v` should return the version'
  it '`roots --version` should return the version'
  it '`roots` should return help'
  it '`roots xxx` should return an error'
  it '`roots help` should return help text'
  it '`roots help -q` should not log output'
  it '`roots help --quiet` should not log output'

  describe 'new', ->
    it '`roots new` should error'
    it '`roots new blah` should create a new project called blah'

  describe 'compile', ->
    it '`roots compile` should compile a project'
    it '`roots compile /path/etc` should compile a project at a path'

  describe 'watch', ->
    it '`roots watch` should watch a project'
    it '`roots watch /path/etc` should watch a project at a path'

  describe 'tpl', ->
    it '`roots tpl` should return help'
    it '`roots tpl add name` should error'
    it '`roots tpl add name url` should add a template'
    it '`roots tpl remove` should error'
    it '`roots tpl remove name` should remove a template'
    it '`roots tpl list` should list templates'
    it '`roots tpl default` should error'
    it '`roots tpl default name` should make a template the default'
