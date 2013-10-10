should = require 'should'
path = require 'path'
fs = require 'fs'
colors = require 'colors'
shell = require 'shelljs'
config = require '../lib/global_config'
run = require('child_process').exec

root = __dirname

# 
# test helpers
# 

require('./helpers')(should)

remove = (test_path) ->
  shell.rm('-rf', test_path)

run_in_dir = (dir, cmd, cb) ->
  run("cd \"#{dir}\"; #{path.join(path.relative(dir, __dirname), '../bin/roots')} #{cmd}", cb)

#
# command line interface
#

describe 'command', ->

  describe 'compile', ->

    before (done) ->
      @root = path.join(root, 'basic')
      @output = path.join(@root, 'public')
      run_in_dir(@root, 'compile', done)

    it 'should compile files to /public', ->
      should.exist(@output, [
        'index.html'
        'favicon.ico'
        'img/noise.png'
        'js/main.js'
        'js/pie.htc'
        'js/require.js'
        'css/example.css'
      ])

    it 'should minify all css and javascript', ->
      js_content = fs.readFileSync path.join(@root, 'public/js/main.js'), 'utf8'
      js_content.should.not.match /\n/

    it 'should compile all files to public', ->
      css_content = fs.readFileSync path.join(@root, 'public/css/example.css'), 'utf8'
      css_content.should.not.match /\n/

    after -> remove(path.join(@root, 'public'))

  describe 'new', ->

    before ->
      @output = path.join(root, 'testproj')

    it 'should use the template set in global config if no flags present', (done) ->
      default_tmpl = config.get().templates.default
      run_in_dir root, 'new testproj', =>
        should.match_dir(@output, path.join(root, "../templates/new/#{default_tmpl}"))
        done()

    it 'should use the default template if the --default flag is present', (done) ->
      run_in_dir root, 'new testproj --default', =>
        should.match_dir(@output, path.join(root, '../templates/new/default'))
        done()

    it 'should use express template if the --express flag is present', (done) ->
      run_in_dir root, 'new testproj --express', =>
        should.match_dir(@output, path.join(root, '../templates/new/express'))
        done()

    it 'should use basic template if the --basic flag is present', (done) ->
      run_in_dir root, 'new testproj --basic', =>
        should.match_dir(@output, path.join(root, '../templates/new/basic'))
        done()

    it 'should use blog template if the --blog flag is present', (done) ->
      run_in_dir root, 'new testproj --blog', =>
        should.match_dir(@output, path.join(root, '../templates/new/blog'))
        done()

    it 'should use min template if the --min flag is present', (done) ->
      run_in_dir root, 'new testproj --min', =>
        should.match_dir(@output, path.join(root, '../templates/new/min'))
        done()

    it 'should use marionette template if the --marionette flag is present', (done) ->
      run_in_dir root, 'new testproj --marionette', =>
        should.match_dir(@output, path.join(root, '../templates/new/marionette'))
        done()

    it 'should use ejs template if the --ejs flag is present', (done) ->
      run_in_dir root, 'new testproj --ejs', =>
        should.match_dir(@output, path.join(root, '../templates/new/ejs'))
        done()

    afterEach -> remove(@output)

  describe 'plugin', ->

    before ->
      @root = path.join(root, 'basic')
      @output = path.join(@root, 'plugins')

    it 'should create a template inside /plugins on \'generate\'', (done) ->
      run_in_dir @root, 'plugin generate', =>
        should.exist(@output, 'template.coffee')
        done()

    it 'should use the javascript template if called with --js', (done) ->
      run_in_dir @root, 'plugin generate --js', =>
        should.exist(@output, 'template.js')
        done()

    afterEach -> remove(path.join(@root, 'plugins'))

  describe 'version', ->
    it 'should output the correct version number for roots', (done) ->
      version = JSON.parse(fs.readFileSync('package.json')).version
      run_in_dir '.', 'version', (err, out) ->
        out.replace(/\n/, '').should.eql(version)
        done()

  describe 'pkg', ->
    
    before ->
      @root = path.join(root, 'basic')

    it 'should expose the correct package manager\'s interface', (done) ->
      pkg_mgr = config.get().package_manager

      run_in_dir @root, 'pkg', (err, out) ->
        if (pkg_mgr == 'cdnjs') then out.should.match /cli-js/
        if (pkg_mgr == 'bower') then out.should.match /bower/
        done()

  describe 'template', ->

    before ->
      @output = path.join(root, 'testproj')
      @tmpl_path = path.join(root, '../templates/new/test')

    it 'should load custom templates correctly', (done) ->
      run_in_dir '.', "template add test https://github.com/jenius/cli-js.git", =>
        run_in_dir root, "new testproj --test", =>
          should.exist(@output, 'package.json')
          done()

    after ->
      remove(@output)
      remove(@tmpl_path)
      config.remove('templates', 'test')

  describe 'clean', ->

    before ->
      @root = path.join(root, 'basic')

    it 'should remove public directory', (done) ->
      run_in_dir @root, 'compile', =>
        should.exist(@root, 'public')
        run_in_dir @root, 'clean', =>
          should.not_exist(@root, 'public')
          done()

describe 'ignores', ->

  before (done) ->
    @root = path.join(root, 'ignores')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should ignore plugins, public, and app.coffee', ->
    should.exist(@output, 'index.html')
    should.not_exist(@output, 'plugins')
    should.not_exist(@output, 'app.coffee')
    should.not_exist(@output, 'public')

  it 'should correctly ignore files from app.coffee', ->
    should.not_exist(@output, 'ignore_me.html')

  it 'should correctly ignore folders from app.coffee', ->
    should.not_exist(@output, 'nobody_loves_me/waaaaah.html')

  after -> remove(@output)

describe 'config options', ->

  before (done) ->
    @root = path.join(root, 'config')
    @output = path.join(@root, 'snargles')
    run_in_dir(@root, 'compile --no-compress', done)

  # If the old-formatted config file doesn't work, all these tests
  # will fail. So this is also an implicit test for that.

  it 'output folder should be configurable', ->
    should.exist(@output, 'index.html')

  it 'views directory should be configurable', ->
    should.exist(@output, 'foo.html')

  it 'assets directory should be configurable', ->
    should.exist(@output, 'bar.css')

  after -> remove(@output)

# 
# extensions
# 

describe 'layouts', ->

  before (done) ->
    @root = path.join(root, 'layouts/no-layout')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should compile templates with no layout', ->
    should.exist(@output, 'index.html')

  after -> remove(@output)

# 
# adapters
# 

describe 'jade', ->
  
  before (done) ->
    @root = path.join(root, 'compile_adapters/jade')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should compile templates with no layout', ->
    should.exist(@output, 'index.html')

  after -> remove(@output)

describe 'ejs', ->

  before (done) ->
    @root = path.join(root, 'compile_adapters/ejs')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should compile ejs', ->
    should.exist(@output, 'index.html')

  after -> remove(@output)

describe 'coffeescript', ->

  before ->
    @root1 = path.join(root, 'compile_adapters/coffeescript')
    @output1 = path.join(@root1, 'public')
    @root2 = path.join(root, 'compile_adapters/coffee-basic')
    @output2 = path.join(@root2, 'public')

  it 'should compile coffeescript and requires should work', (done) ->
    run_in_dir @root1, 'compile --no-compress', =>
      should.exist(@output1, ['basic.js', 'require.js'])
      should.contain_content(@output1, 'require.js', /BASIC/)
      done()

  it 'should compile without closures when specified in app.coffee', (done) ->
    run_in_dir @root2, 'compile --no-compress', =>
      should.exist(@output2, 'testz.js')
      should.not_contain_content(@output2, 'testz.js', /function/)
      done()

  after ->
    remove(@output1)
    remove(@output2)

describe 'stylus', ->

  before (done) ->
    @root = path.join(root, 'compile_adapters/stylus')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should compile stylus with roots css', ->
    should.exist(@output, 'basic.css')

  it 'should include the project directory for requires', ->
    should.exist(@output, ['req.css', 'nested/all.css'])
    should.contain_content(@output, 'req.css', /#000/)

  after ->
    remove(@output)

describe 'scss', ->
  test_path = path.join root, './scss'

  before (done) ->
    @root = path.join(root, 'compile_adapters/scss')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'should compile scss with roots css', ->
    should.exist(@output, 'basic.css')
    should.match_file(@output, 'basic.css', 'expected-basic.css')

  it 'should compile scss with imports', ->
    should.exist(@output, 'imports.css')
    should.match_file(@output, 'imports.css', 'expected-imports.css')

  it 'should not compile scss partials', ->
    should.not_exist(@output, '_cats.css')

  after -> remove(@output)

describe 'static files', ->

  before (done) ->
    @root = path.join(root, 'static')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'copies static files', ->
    should.exist(@output, 'whatever.poop')
    should.contain_content(@output, 'whatever.poop', /roots dont care/)

  after -> remove(@output)

# 
# misc
# 

describe 'errors', ->

  before ->
    @root = path.join(root, 'errors')
    @output = path.join(@root, 'public')

  it 'notifies you if theres an error', (done) ->
    run_in_dir @root, 'compile --no-compress', (err, out, stderr) ->
      stderr.should.match /ERROR/
      done()

  after -> remove(@output)

describe 'dynamic content', ->

  before (done) ->
    @root = path.join(root, 'dynamic_content/basic')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'compiles dynamic files', ->
    should.exist(@output, ['posts/hello_world.html', 'posts/second_post.html'])
    should.contain_content(@output, 'posts/hello_world.html', /\<h1\>hello world\<\/h1\>/)
    should.contain_content(@output, 'posts/hello_world.html', /This is my first blog post/)

  it 'makes front matter available as locals', ->
    should.exist(@output, 'index.html')
    should.contain_content(@output, 'index.html', /\<a href="\/posts\/hello_world.html"\>hello world\<\/a\>/)

  it 'exposes compiled content as site.post.contents', ->
    should.contain_content(@output, 'index.html', /\<p\>This is my first blog post.*\<\/p\>/)

  after -> remove(@output)

describe 'nested dynamic content', ->

  before (done) ->
    @root = path.join(root, 'dynamic_content/complex')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'compiles nested dynamic content', ->
    should.exist(@output, 'posts/code/bar.html')
    should.exist(@output, 'posts/code/quuz.html')
    should.exist(@output, 'posts/baz.html')
    should.contain_content(@output, 'posts/code/bar.html', /blarg world/) 
    should.contain_content(@output, 'posts/code/quuz.html', /blarg\!/) 

  it 'adds nested dynamic content correctly to locals', ->
    should.contain_content(@output, 'index.html', /my name is blarg/)
    should.contain_content(@output, 'index.html', /foo/)
    should.contain_content(@output, 'index.html', /blarg world/)
    should.contain_content(@output, 'index.html', /quuuuuuux homie/)

  it 'correctly links nested dynamic content with \'url\'', ->
    should.contain_content(@output, 'index.html', /href="\/posts\/code\/bar\.html"/)
    should.contain_content(@output, 'index.html', /href="\/posts\/baz\.html"/)

  after -> remove(@output)

describe 'precompiled templates', ->

  before (done) ->
    @root = path.join(root, 'precompile')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'precompiles templates', ->
    should.exist(@output, '/js/templates.js')
    should.contain_content(@output, 'js/templates.js', /\<p\>hello world\<\/p\>/)

  after -> remove(@output)

describe 'multipass compiles', ->

  before (done) ->
    @root = path.join(root, 'multipass')
    @output = path.join(@root, 'public')
    run_in_dir(@root, 'compile --no-compress', done)

  it 'will compile a single file multiple times accurately', ->
    should.exist(@output, 'index.html')
    should.contain_content(@output, 'index.html', /blarg world/)

  after -> remove(@output)

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
