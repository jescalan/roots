try
  posix = require 'posix'
catch
  posix = null

before (done) ->
  util.project.install_dependencies('*/*', done)

after ->
  util.project.remove_folders('**/public')

describe 'constructor', ->

  it 'fails when given nonexistant path', ->
    (-> project = new Roots('sdfsdfsd')).should.throw(Error)

  it 'exposes config and root', ->
    project = new Roots(path.join(base_path, 'compile/basic'))
    project.root.should.exist
    project.config.should.exist

  if (posix)
    describe 'open file limit', ->
      before -> @limit = process.env['ROOTS_RLIMIT'] = 5000

      it 'raises the limit according to the environment', ->
        project = new Roots(path.join(base_path, 'compile/basic'))
        posix.getrlimit('nofile').soft.should.equal(@limit)
