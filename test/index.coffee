if require('os').platform() is 'win32'
  posix = null
else
  posix  = require 'posix'

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

    describe 'open file limit', ->
      before ->
        return unless posix

        @limit = process.env['ROOTS_RLIMIT'] = 5000

      it 'raises the limit according to the environment', ->
        return unless posix

        project = new Roots(path.join(base_path, 'compile/basic'))
        posix.getrlimit('nofile').soft.should.equal(@limit)
