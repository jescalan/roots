should = require 'should'
path = require 'path'
fs = require 'fs'
colors = require 'colors'
shell = require 'shelljs'
run = require('child_process').exec
root = path.join __dirname

#
# command line interface
#

# can't test watch because the process hangs - the internals of
# the watch command are tested below in the compiler section though

files_exist = (test_path, files) ->
  for file in files
    fs.existsSync(path.join(test_path, file)).should.be.ok

describe 'command', ->
  basic_root = path.join root, 'sandbox/basic'

  describe 'compile', -> # ----------------------------------------------------------------
    before (done) ->
      run "cd \"#{basic_root}\"; ../../../bin/roots compile", done

    it 'should compile files to /public', ->
      fs.readdirSync(path.join(basic_root, 'public')).should.have.lengthOf(5)

    it 'should minify all css and javascript', () ->
      js_content = fs.readFileSync path.join(basic_root, 'public/js/main.js'), 'utf8'
      js_content.should.not.match /\n/

    it 'should compile all files to public', ->
      css_content = fs.readFileSync path.join(basic_root, 'public/css/example.css'), 'utf8'
      css_content.should.not.match /\n/
      shell.rm '-rf', path.join(basic_root, 'public')

  describe 'new', -> # --------------------------------------------------------------------
    test_path = path.join(root, 'testproj')

    it 'should use the default template if no flags present', (done) ->
      run "cd \"#{root}\"; ../bin/roots new testproj", ->
        files_exist(test_path,[
          '/'
          'app.coffee'
          'readme.md'
          'views'
          'views/index.jade'
          'views/layout.jade'
          'assets'
          'assets/favicon.ico'
          'assets/css'
          'assets/css/_settings.styl'
          'assets/css/master.styl'
          'assets/js'
          'assets/js/main.coffee'
          'assets/js/_helper.coffee'
          'assets/js/require.js'
          'assets/img'
          'assets/img/noise.png'
        ])
        shell.rm '-rf', path.join(root, 'testproj')
        done()

    it 'should use express template if the --express flag is present', (done) ->
      run "cd \"#{root}\"; ../bin/roots new testproj --express", ->
        files_exist(test_path,[
          '/'
          'app.js'
          'routes'
          'assets'
          'views'
          'public'
        ])
        shell.rm '-rf', path.join(root, 'testproj')
        done()

    it 'should use basic template if the --basic flag is present', (done) ->
      run "cd \"#{root}\"; ../bin/roots new testproj --basic", ->
        files_exist(test_path,[
          '/'
          'views/index.html'
          'assets/js/main.js'
          'assets/css/example.css'
        ])
        shell.rm '-rf', path.join(root, 'testproj')
        done()

  describe 'plugin', -> # -----------------------------------------------------------------
    it 'should create a template inside /plugins on \'generate\'', (done) ->
      run "cd \"#{basic_root}\"; ../../../bin/roots plugin generate", ->
        files_exist(basic_root, ['plugins/template.coffee'])
        shell.rm '-rf', path.join(basic_root, 'plugins')
        done()

    it 'should use the javascript template if called with --js', (done) ->
      run "cd \"#{basic_root}\"; ../../../bin/roots plugin generate --js", ->
        files_exist(basic_root, ['plugins/template.js'])
        shell.rm '-rf', path.join(basic_root, 'plugins')
        done()

  describe 'version', -> # ----------------------------------------------------------------
    it 'should output the correct version number for roots', (done) ->
      version = JSON.parse(fs.readFileSync('package.json')).version
      run './bin/roots version', (err,out) ->
        out.replace(/\n/, '').should.eql(version)
        done()

  describe 'js', -> # ---------------------------------------------------------------------
    it 'should expose bower\'s interface', (done) ->
      run "cd \"#{basic_root}\"; ../../../bin/roots js", (err,out, stdout) ->
        out.should.match /bower/
        done()

describe 'compiler', ->
  compiler = null

  before ->
    Compiler = require path.join(root, '../lib/compiler')
    compiler = new Compiler()

  it 'eventemitter should be hooked up properly', (done) ->
    compiler.on 'finished', -> done()
    compiler.finish()

describe 'jade', ->
  it 'should compile jade view templates', (done) ->
    jade_path = path.join root, 'sandbox/jade'
    run "cd \"#{jade_path}\"; ../../../bin/roots compile --no-compress", ->
      files_exist(jade_path, ['public/index.html'])
      shell.rm '-rf', path.join(jade_path, 'public')
      done()

  it 'should compile templates with no layout', (done) ->
    jade_path_2 = path.join root, 'sandbox/no-layout'
    run "cd #{jade_path_2}; ../../../bin/roots compile --no-compress", ->
      files_exist(jade_path_2, ['public/index.html'])
      shell.rm '-rf', path.join(jade_path_2, 'public')
      done()

describe 'ejs', ->
  it 'should compile ejs', (done) ->
    file_path = path.join root, 'sandbox/ejs'
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      files_exist(file_path, ['public/index.html'])
      shell.rm '-rf', path.join(file_path, 'public')
      done()

describe 'coffeescript', ->
  it 'should compile coffeescript and requires should work', (done) ->
    file_path = path.join root, 'sandbox/coffeescript'
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      files_exist(file_path, ['public/basic.js', 'public/require.js'])
      require_content = fs.readFileSync path.join(file_path, 'public/require.js'), 'utf8'
      require_content.should.match /BASIC/
      shell.rm '-rf', path.join(file_path, 'public')
      done()

  it 'should compile without closures when specified in app.coffee', (done) ->
    file_path = path.join root, 'sandbox/coffee-basic'
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      files_exist(file_path, ['public/testz.js'])
      require_content = fs.readFileSync path.join(file_path, 'public/testz.js'), 'utf8'
      require_content.should.not.match /function/
      shell.rm '-rf', path.join(file_path, 'public')
      done()

describe 'stylus', ->
  file_path = path.join root, 'sandbox/stylus'

  before (done) ->
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      done()

  it 'should compile stylus with roots css', ->
    files_exist(file_path, ['public/basic.css'])

  it 'should include the project directory for requires', ->
    files_exist(file_path, ['public/req.css', 'public/nested/all.css'])
    require_content = fs.readFileSync path.join(file_path, 'public/req.css'), 'utf8'
    require_content.should.match /#000/
    shell.rm '-rf', path.join(file_path, 'public')

describe 'static files', ->
  file_path = path.join root, 'sandbox/static'

  before (done) ->
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      done()

  it 'copies static files', ->
    files_exist(file_path, ['public/whatever.poop'])
    require_content = fs.readFileSync path.join(file_path, 'public/whatever.poop'), 'utf8'
    require_content.should.match /roots dont care/
    shell.rm '-rf', path.join(file_path, 'public')

describe 'errors', ->
  it 'notifies you if theres an error', (done) ->
    file_path = path.join root, 'sandbox/errors'
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", (a,b,stderr) ->
      stderr.should.match /ERROR/
      done()

describe 'dynamic content', ->
  file_path = path.join root, 'sandbox/dynamic'

  before (done) ->
    run "cd \"#{file_path}\"; ../../../bin/roots compile --no-compress", ->
      done()

  it 'compiles dynamic files', ->
    files_exist(file_path, ['public/posts/hello_world.html'])
    content = fs.readFileSync path.join(file_path, 'public/posts/hello_world.html'), 'utf8'
    content.should.match(/\<h1\>hello world\<\/h1\>/)
    content.should.match(/This is my first blog post/)
    shell.rm '-rf', path.join(file_path, 'public')

describe 'precompiled templates', ->
  file_path = path.join root, 'sandbox/precompile'

  before (done) ->
    run "cd #{file_path}; ../../../bin/roots compile --no-compress", ->
      done()

  it 'precompiles templates', ->
    files_exist(file_path, ['public/js/templates.js'])
    require_content = fs.readFileSync path.join(file_path, 'public/js/templates.js'), 'utf8'
    require_content.should.match(/\<p\>hello world\<\/p\>/)
    shell.rm '-rf', path.join(file_path, 'public')

describe 'multipass compiles', ->
  file_path = path.join root, 'sandbox/multipass'

  before (done) ->
    run "cd #{file_path}; ../../../bin/roots compile --no-compress", ->
      done()

  it 'will compile a single file multiple times accurately', ->
    files_exist(file_path, ['public/index.html'])
    content = fs.readFileSync path.join(file_path, 'public/index.html'), 'utf8'
    content.should.match(/blarg world/)
    shell.rm '-rf', path.join(file_path, 'public')

describe 'deploy', ->
  deployer = null

  before ->
    Deployer = require path.join(root, '../lib/deployer')
    test_adapter = { test: (input)-> return input }
    deployer = new Deployer(test_adapter, '')
    deployer.add_shell_method('test');

  it 'handles adapters correctly', ->
    deployer.test(true).should.be.ok
    deployer.test(false).should.not.be.ok

  it 'has all the required shell methods', ->
    deployer.check_install_status.should.exist
    deployer.check_credentials.should.exist
    deployer.compile_project.should.exist
    deployer.add_config_files.should.exist
    deployer.commit_files.should.exist
    deployer.create_project.should.exist
    deployer.push_code.should.exist
