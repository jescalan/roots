rimraf = require 'rimraf'
test_path = path.join(base_path, 'compile')

describe 'compile', ->

  it 'should compile files in nested directories', (done) ->
    p = path.join(test_path, 'basic')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      paths_exist(output, [
        'index.html',
        'LECHUCK_ALE',
        'nested/foo.html',
        'nested/double_nested/bar.html',
        'unicode_land.html',
        'empty.html'
      ])
      fs.statSync(path.join(output, "doge.png")).size.should.equal(fs.statSync(path.join(p, "doge.png")).size)
      path.join(output, 'unicode_land.html').should.have.content("<p>å sky so hîgh ☆</p><p>ƒloat üp and down ☂</p><p>süch air in face wow ♞</p>")
      done()

  it 'should copy files in nested directories', (done) ->
    p = path.join(test_path, 'copy')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      paths_exist(output, ['foo.html', 'nested/bar.html', 'nested/whatever.blah'])
      done()

  it 'should check devDependancies for compilers', (done) ->
    p = path.join(test_path, 'dev_deps')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      paths_exist(output, ['index.html'])
      done()

  it 'should load a simple app config', (done) ->
    p = path.join(test_path, 'simple_config')
    output = path.join(p, 'foobar')

    compile_fixture p, done, ->
      path.join(output, 'tests.html').should.be.a.file()
      rimraf(output, done)

  it 'should ignore specified files', (done) ->
    p = path.join(test_path, 'ignores')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      paths_dont_exist(output, ['ignoreme.html', 'foo'])
      path.join(output, 'nested_ignore.html').should.be.a.file()
      done()

  it 'should dump specified dirs', (done) ->
    p = path.join(test_path, 'dump_dirs')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      paths_exist(output, ['index.html', 'css/foo.css'])
      paths_dont_exist(output, ['views', 'assets'])
      done()

  it 'should accept custom compiler options', (done) ->
    p = path.join(test_path, 'compiler_options')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      path.join(output, 'index.html').should.be.a.file()
      matches_file(output, 'index.html', 'index_expected.html')
      done()

  it 'should use locals', (done) ->
    p = path.join(test_path, 'locals')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      path.join(output, 'index.html').should.be.a.file()
      matches_file(output, 'index.html', 'index_expected.html')
      done()

  it 'should run before and after hooks', (done) ->
    p = path.join(test_path, 'hooks')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      path.join(output, 'before.txt').should.be.a.file()
      path.join(output, 'after.txt').should.be.a.file()
      rimraf(path.join(p, 'before.txt'), done)

  it 'should correctly handle multipass compiles', (done) ->
    p = path.join(test_path, 'multipass')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      p1 = path.join(output, 'foo.html')
      p2 = path.join(output, 'bar.html')
      p3 = path.join(output, 'baz.html')
      p4 = path.join(output, 'quux.html')

      p1.should.be.a.file()
      p1.should.have.content("<p>wow</p>")
      p2.should.be.a.file()
      p2.should.have.content("<p>wow</p>")
      p3.should.be.a.file()
      p3.should.have.content("<p>so compile</p>")
      p4.should.be.a.file()
      p4.should.have.content("<p>so compile</p>")

      done()

  it 'should be able to handle strange filenames', (done) ->
    p = path.join(test_path, 'weird_filenames')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      path.join(output, 'foo bar.wow').should.be.a.file()
      path.join(output, 'pesta#na.md').should.be.a.file()
      path.join(output, 'doge.eats.twerking-cyrus-tm-___cat.png').should.be.a.file()
      path.join(output, 'folder.withdot').should.be.a.directory()
      path.join(output, 'folder.withdot/.dotfile.wow').should.be.a.file()
      path.join(output, 'folder.withdot/file.something.other.js').should.be.a.file()
      path.join(output, 'folder.withdot/look@mybiceps').should.be.a.file()
      path.join(output, 'folder.withdot/manyOf∫chin').should.be.a.directory()
      path.join(output, 'folder.withdot/manyOf∫chin/er mer .gerd.wat').should.be.a.file()
      done()

  it 'should compile correctly if any of the project\'s parent directories have a dot in their name', (done) ->
    p = path.join(test_path, 'dir.with_dot')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      path.join(output, 'manatoge.html').should.be.a.file()
      done()

  it 'should have the file\'s url path available locally in views', (done) ->
    p = path.join(test_path, 'path_helper')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      p = path.join(output, 'path_helper.html')
      p.should.be.a.file()
      p.should.have.content('/path_helper.html')
      done()

  it 'should work with different environments', (done) ->
    p = path.join(test_path, 'environments')
    output = path.join(p, 'public')

    (new Roots(p, { env: 'doge' })).compile().done ->
      path.join(output, 'doge_file.html').should.be.a.file()
      path.join(output, 'dev_file.html').should.not.be.a.path()
      done()
    , done

  it 'should output sourcemaps when specified', (done) ->
    p = path.join(test_path, 'sourcemaps')
    output = path.join(p, 'public')

    compile_fixture p, done, ->
      p = path.join(output, 'test.css')
      p.should.be.a.file()
      p2 = path.join(output, 'test.css.map')
      p2.should.be.a.file()
      p3 = path.join(output, 'test.js')
      p3.should.be.a.file()
      p4 = path.join(output, 'test.js.map')
      p4.should.be.a.file()

      sm1 = JSON.parse(fs.readFileSync(p2, 'utf8'))
      sm2 = JSON.parse(fs.readFileSync(p4, 'utf8'))

      sm1.version.should.equal(3)
      sm2.version.should.equal(3)
      sm1.file.should.equal('test.css')
      sm2.file.should.equal('test.js')
      sm1.mappings.length.should.be.above(1)
      sm2.mappings.length.should.be.above(1)

      done()
