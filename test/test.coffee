should = require 'should'
path = require 'path'
fs = require 'fs'
colors = require 'colors'
shell = require 'shelljs'
config = require '../lib/global_config'
run = require('child_process').exec

root = __dirname

#
# command line interface
#

# can't test watch because the process hangs - the internals of
# the watch command are tested below in the compiler section though

files_exist = (test_path, files) ->
  for file in files
    fs.existsSync(path.join(test_path, file)).should.equal(
      true,
      "expected #{path.join(test_path, file)} to exist"
    )

remove = (test_path) ->
  shell.rm('-rf', test_path)

describe 'command', ->
  basic_root = path.join root, 'basic'

  describe 'compile', ->
    before (done) ->
      run "cd \"#{basic_root}\"; ../../bin/roots compile", done

    it 'should compile files to /public', ->
      files_exist(path.join(basic_root, 'public'),[
        'index.html'
        'favicon.ico'
        'img/noise.png'
        'js/main.js'
        'js/pie.htc'
        'js/require.js'
        'css/example.css'
      ])
      #fs.readdirSync(path.join(basic_root, 'public')).should.have.lengthOf(5)

    it 'should minify all css and javascript', ->
      js_content = fs.readFileSync path.join(basic_root, 'public/js/main.js'), 'utf8'
      js_content.should.not.match /\n/

    it 'should compile all files to public', ->
      css_content = fs.readFileSync path.join(basic_root, 'public/css/example.css'), 'utf8'
      css_content.should.not.match /\n/

    after ->
      remove path.join(basic_root, 'public')

  describe 'new', ->
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
        done()

    it 'should use basic template if the --basic flag is present', (done) ->
      run "cd \"#{root}\"; ../bin/roots new testproj --basic", ->
        files_exist(test_path,[
          '/'
          'views/index.html'
          'assets/js/main.js'
          'assets/css/example.css'
        ])
        done()

    afterEach ->
        remove path.join(root, 'testproj')

  describe 'plugin', ->
    it 'should create a template inside /plugins on \'generate\'', (done) ->
      run "cd \"#{basic_root}\"; ../../bin/roots plugin generate", ->
        files_exist basic_root, ['plugins/template.coffee']
        done()

    it 'should use the javascript template if called with --js', (done) ->
      run "cd \"#{basic_root}\"; ../../bin/roots plugin generate --js", ->
        files_exist basic_root, ['plugins/template.js']
        done()

    afterEach ->
        remove path.join(basic_root, 'plugins')

  describe 'version', ->
    it 'should output the correct version number for roots', (done) ->
      version = JSON.parse(fs.readFileSync('package.json')).version
      run './bin/roots version', (err,out) ->
        out.replace(/\n/, '').should.eql(version)
        done()

  describe 'pkg', ->
    test_repo = 'https://github.com/jenius/cli-js.git'
    test_name = 'test'
    test_path = path.join(root, 'testproj')
    tmpl_path = path.join(root, '../templates/new', test_name)

    it 'should expose the correct package manager\'s interface', (done) ->
      pkg_mgr = config.get().package_manager
      run "cd \"#{basic_root}\"; ../../bin/roots pkg", (err,out, stdout) ->
        out.should.match /cli-js/ if (pkg_mgr == 'cdnjs')
        out.should.match /bower/ if (pkg_mgr == 'bower')
        done()

    it 'should load custom templates correctly', (done) ->
      run "./bin/roots template add test #{test_repo}", ->
        run "cd #{root}; ../bin/roots new testproj --#{test_name}", (err) ->
          files_exist test_path, ['/', 'package.json']
          config.remove('templates', 'test')
          done()

    after ->
      remove test_path
      remove tmpl_path

  describe 'clean', ->
    basic_root = path.join(root, 'basic')

    it 'should remove public directory', (done) ->
      run "cd #{basic_root}; ../../bin/roots compile", ->
        run "cd #{basic_root}; ../../bin/roots clean", (err) ->
          fs.existsSync(path.join(basic_root, 'public')).should.be.false
          done()

describe 'compiler', ->
  compiler = null

  before ->
    roots = require path.join(root, '../lib/index')
    compiler = roots.compiler

  it 'eventemitter should be hooked up properly', (done) ->
    compiler.on 'finished', -> done()
    compiler.finish()

describe 'config options', ->

  it 'old and new formatted app.coffee files should work'
  it 'output folder should be configurable'
  it 'views directory should be configurable'
  it 'assets directory should be configurable'
  it 'should ignore layout files, plugins, public, and app.coffee'
  it 'should correctly ignore files'
  it 'should correctly ignore folders'

describe 'jade', ->
  test_path = path.join root, './jade'
  test_path_2 = path.join root, './no-layout'

  it 'should compile jade view templates', (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      files_exist test_path, ['public/index.html']
      remove path.join(test_path, 'public')
      done()

  it 'should compile templates with no layout', (done) ->
    run "cd #{test_path_2}; ../../bin/roots compile --no-compress", ->
      files_exist test_path_2, ['public/index.html']
      remove path.join(test_path_2, 'public')
      done()

describe 'ejs', ->
  test_path = path.join root, './ejs'

  it 'should compile ejs', (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      files_exist test_path, ['public/index.html']
      done()

  after ->
    remove path.join(test_path, 'public')

describe 'coffeescript', ->
  test_path = path.join root, './coffeescript'
  test_path_2 = path.join root, './coffee-basic'

  it 'should compile coffeescript and requires should work', (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      files_exist test_path, ['public/basic.js', 'public/require.js']
      require_content = fs.readFileSync path.join(test_path, 'public/require.js'), 'utf8'
      require_content.should.match /BASIC/
      done()

  it 'should compile without closures when specified in app.coffee', (done) ->
    run "cd \"#{test_path_2}\"; ../../bin/roots compile --no-compress", ->
      files_exist test_path_2, ['public/testz.js']
      require_content = fs.readFileSync path.join(test_path_2, 'public/testz.js'), 'utf8'
      require_content.should.not.match /function/
      done()

  after ->
    remove path.join(test_path, 'public')
    remove path.join(test_path_2, 'public')

describe 'stylus', ->
  test_path = path.join root, './stylus'

  before (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      done()

  it 'should compile stylus with roots css', ->
    files_exist test_path, ['public/basic.css']

  it 'should include the project directory for requires', ->
    files_exist test_path, ['public/req.css', 'public/nested/all.css']
    require_content = fs.readFileSync path.join(test_path, 'public/req.css'), 'utf8'
    require_content.should.match /#000/

  after ->
    remove path.join(test_path, 'public')

describe 'static files', ->
  test_path = path.join root, './static'

  before (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      done()

  it 'copies static files', ->
    files_exist test_path, ['public/whatever.poop']
    require_content = fs.readFileSync path.join(test_path, 'public/whatever.poop'), 'utf8'
    require_content.should.match /roots dont care/

  after ->
    remove path.join(test_path, 'public')

describe 'errors', ->
  test_path = path.join root, './errors'

  it 'notifies you if theres an error', (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", (a,b,stderr) ->
      stderr.should.match /ERROR/
      done()

  after ->
    remove path.join(test_path, 'public')

describe 'dynamic content', ->
  test_path = path.join root, './dynamic'

  before (done) ->
    run "cd \"#{test_path}\"; ../../bin/roots compile --no-compress", ->
      done()

  after ->
    remove path.join(test_path, 'public')

  it 'compiles into single post templates', ->
    files_exist test_path, [
      'public/posts/hello_world.html'
      'public/posts/second_post.html'
    ]
    content = fs.readFileSync path.join(test_path, 'public/posts/hello_world.html'), 'utf8'
    content.should.match(/\<h1\>hello world\<\/h1\>/)
    content.should.match(/This is my first blog post/)

  it 'makes front matter available as locals', ->
    fs.existsSync(path.join(test_path, 'public/index.html')).should.be.ok
    content = fs.readFileSync path.join(test_path, 'public/index.html'), 'utf8'
    content.should.match(/\<a href="\/posts\/hello_world.html"\>hello world\<\/a\>/)

  it 'exposes compiled content as site.post.contents', ->
    content = fs.readFileSync path.join(test_path, 'public/index.html'), 'utf8'
    content.should.match(/\<p\>This is my first blog post.*\<\/p\>/)

describe 'precompiled templates', ->
  test_path = path.join root, './precompile'

  before (done) ->
    run "cd #{test_path}; ../../bin/roots compile --no-compress", ->
      done()

  it 'precompiles templates', ->
    files_exist test_path, ['public/js/templates.js']
    require_content = fs.readFileSync path.join(test_path, 'public/js/templates.js'), 'utf8'
    require_content.should.match(/\<p\>hello world\<\/p\>/)

  after ->
    remove path.join(test_path, 'public')

describe 'multipass compiles', ->
  test_path = path.join root, './multipass'

  before (done) ->
    run "cd #{test_path}; ../../bin/roots compile --no-compress", ->
      done()

  it 'will compile a single file multiple times accurately', ->
    files_exist test_path, ['public/index.html']
    content = fs.readFileSync path.join(test_path, 'public/index.html'), 'utf8'
    content.should.match(/blarg world/)

  after ->
    remove path.join(test_path, 'public')

describe 'deploy', ->
  deployer = null

  before ->
    Deployer = require path.join(root, '../lib/deployer')
    test_adapter =
      test: (input)-> return input
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
