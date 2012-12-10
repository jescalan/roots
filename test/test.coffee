should = require 'should'
path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
colors = require 'colors'
run = require('child_process').exec
root = path.join process.cwd(), 'test'

# 
# command line interface
# 

describe 'command', ->
  cli_root = path.join root, 'cli'
  
  describe 'compile', ->

    before (done) ->
      run "cd #{cli_root}; ../../bin/roots compile", (a,b,c) -> done()

    it 'should compile files to /public', ->
      fs.readdirSync(path.join(cli_root, 'public')).should.have.lengthOf(5)

    it 'should minify all css and javascript', () ->
      js_content = fs.readFileSync path.join(cli_root, 'public/js/main.js'), 'utf8'
      js_content.should.not.match /\n/

    it 'should compile all files to public', ->
      css_content = fs.readFileSync path.join(cli_root, 'public/css/example.css'), 'utf8'
      css_content.should.not.match /\n/

  describe 'new', ->
    it 'should create a new folder in the current directory with the right name and files', (done) ->
      run "cd #{root}; ../bin/roots new testproj", ->
        test_path = path.join(root, 'testproj')
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'app.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'readme.md')).should.be.ok
        fs.existsSync(path.join(test_path, 'views')).should.be.ok
        fs.existsSync(path.join(test_path, 'views/index.jade')).should.be.ok
        fs.existsSync(path.join(test_path, 'views/layout.jade')).should.be.ok
        fs.existsSync(path.join(test_path, 'views/index.jade')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/favicon.ico')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/_settings.styl')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/example.styl')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/main.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/_helper.coffee')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/pie.htc')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/require.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/img')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/img/noise.png')).should.be.ok
        rimraf.sync path.join(root, 'testproj')
        done()

    it 'should use express template if the --express flag is present', (done) ->
      run "cd #{root}; ../bin/roots new testproj --express", ->
        test_path = path.join(root, 'testproj')
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'app.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'routes')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets')).should.be.ok
        fs.existsSync(path.join(test_path, 'views')).should.be.ok
        fs.existsSync(path.join(test_path, 'public')).should.be.ok
        rimraf.sync path.join(root, 'testproj')
        done()

    it 'should use basic template if the --basic flag is present', (done) ->
      run "cd #{root}; ../bin/roots new testproj --basic", ->
        test_path = path.join(root, 'testproj')
        fs.existsSync(test_path).should.be.ok
        fs.existsSync(path.join(test_path, 'views/index.html')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/js/main.js')).should.be.ok
        fs.existsSync(path.join(test_path, 'assets/css/example.css')).should.be.ok
        rimraf.sync path.join(root, 'testproj')
        done()

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