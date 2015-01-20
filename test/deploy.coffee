node = require 'when/node'

describe 'deploy', ->

  it 'deploys and prompts for input when shipfile not present', ->
    p = path.join(base_path, 'deploy/no_shipfile')
    project = new Roots(p)

    project.deploy(to: 'nowhere')
      .progress (prompt) -> prompt.rl.emit("line", "wow")
      .tap (ship) -> node.call(fs.unlink, ship.shipfile)
      .catch (err) -> console.log err.stack
      .should.be.fulfilled

  it 'deploys when a shipfile is already present', ->
    p = path.join(base_path, 'deploy/shipfile')
    project = new Roots(p)

    project.deploy(to: 'nowhere').should.be.fulfilled

  it 'compiles before deploy', ->
    p = path.join(base_path, 'deploy/compile')
    project = new Roots(p)

    project.deploy(to: 'nowhere')
    .then -> path.join(p, 'public').should.be.a.directory()
    .then -> path.join(p, 'public/index.html').should.be.a.file()
    .should.be.fulfilled

  it 'removes previous output folder before compiling', ->
    p = path.join(base_path, 'deploy/remove_prev')
    project = new Roots(p)

    fs.mkdirSync(path.join(p, 'public'))
    fs.writeFileSync(path.join(p, 'public/foo.html'), 'foo bar')

    project.deploy(to: 'nowhere')
    .tap -> path.join(p, 'public/foo.html').should.not.be.a.path()
    .tap -> path.join(p, 'public/index.html').should.be.a.file()
    .should.be.fulfilled

  it 'compiles with app.production.coffee if available', ->
    p = path.join(base_path, 'deploy/production')
    project = new Roots(p)

    project.deploy(to: 'nowhere')
    .then -> path.join(p, 'public/index.html').should.have.content('production')
    .catch(console.log)
    .should.be.fulfilled

  it 'compiles with another environment if available', ->
    p = path.join(base_path, 'deploy/another_environment')
    project = new Roots(p, env: 'foo')

    project.deploy(to: 'nowhere')
    .then -> path.join(p, 'public/index.html').should.have.content('foo')
    .catch(console.log)
    .should.be.fulfilled
