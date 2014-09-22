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
