require 'colors'

should = require 'should'
path = require 'path'
fs = require 'fs'
_ = require 'underscore'
shell = require 'shelljs'
config = require '../lib/global_config'
run = require('child_process').exec
root = __dirname

remove = (test_path) ->
  shell.rm('-rf', test_path)

run_in_dir = (dir, cmd, cb) ->
  run("cd \"#{dir}\"; #{path.join(path.relative(dir, __dirname), '../bin/roots')} #{cmd}", cb)

describe 'new', ->

  before ->
    @output = path.join(root, 'testproj')

  it 'should use the template set in global config if no flags present', (done) ->
    default_tmpl = config.get('templates').default
    run_in_dir root, 'new testproj', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match new RegExp(config.get('default_template'))
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use the default template if the --default flag is present', (done) ->
    run_in_dir root, 'new testproj --default', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /default/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use express template if the --express flag is present', (done) ->
    run_in_dir root, 'new testproj --express', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /express/
      should.exist(root, 'testproj/package.json')
      done()

  it 'should use basic template if the --basic flag is present', (done) ->
    run_in_dir root, 'new testproj --basic', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /basic/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use blog template if the --blog flag is present', (done) ->
    run_in_dir root, 'new testproj --blog', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /blog/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use min template if the --min flag is present', (done) ->
    run_in_dir root, 'new testproj --min', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /min/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use marionette template if the --marionette flag is present', (done) ->
    run_in_dir root, 'new testproj --marionette', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /marionette/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should use ejs template if the --ejs flag is present', (done) ->
    run_in_dir root, 'new testproj --ejs', (err, out) =>
      should.not.exist(err)
      out.should.match /new project created/
      out.should.match /ejs/
      should.exist(root, 'testproj/app.coffee')
      done()

  it 'should copy the .gitignore over fom the basic template', (done) ->
    run_in_dir root, 'new testproj --ejs', (err, out) =>
      should.not.exist(err)
      fs.existsSync(path.join(root, 'testproj/.gitignore')).should.be.true
      done()

  afterEach -> remove(@output)
