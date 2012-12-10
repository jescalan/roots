should = require 'should'

# 
# command line interface
# 

describe 'command', ->

  describe 'compile', ->
    it 'should minify all css and javascript'
    it 'should compile all files to public'

  describe 'new', ->
    it 'should create a new folder in the current directory with the specified name'
    it 'should use express template if the --express flag is present'
    it 'should use basic template if the --basic flag is present'
    it 'should create all the necessary files'

  describe 'watch', ->
    it 'should compile the project to /public'
    it 'should reload the browser once when a file is saved'

  describe 'plugin', ->
    it 'should create a new template inside /plugins if generate is called'
    it 'should install a plugin from github if install is called'

  describe 'update', ->
    it 'should run npm update roots -g'
    it 'should update roots\' version'

  describe 'version', ->
    it 'should output the correct version number for roots'

  describe 'js', ->
    it 'should expose bower\'s interface'

# 
# compilers
# 

describe 'compiler', ->

  describe 'stylus', ->
    it 'should compile to css'
    it 'should make the roots css library available'
    it 'should include the project directory for requires'

  describe 'jade', ->
    it 'should compile to html'
    it 'should compile views into default layout'
    it 'should compile views with specified layout files to the right layout'

  describe 'ejs', ->
    it 'should compile to html'
    it 'should compile views into default layout'
    it 'should compile views with specified layout files to the right layout'

  describe 'coffeescript', ->
    it 'should compile to javascript'
    it 'should include other files when #= require ]\'file\' is present'
    it 'should compile without closures when specified in app.coffee'

# 
# compile_project method
# 

describe 'compile project', ->
  it 'should copy files in views directly to the root of /public'
  it 'should copy straight html, css, and javascript files'
  it 'should correctly copy nested directories and files'
  it 'should send the reload command only when all files are compiled'
  it 'should copy images correctly'