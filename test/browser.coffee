Driver     = require 'selenium-webdriver'
chaidriver = require 'chai-webdriver'
CLI        = require '../lib/cli'
fs         = require 'fs'

# cli = new CLI(debug: true)
# driver = new Driver.Builder().withCapabilities(Driver.Capabilities.phantomjs()).build()
# chai.use(chaidriver(driver))
# basic_path = path.join(base_path, 'compile/basic')

describe 'browser', ->

  it.skip 'should compile and serve the site on watch', (done) ->
    cli.run("watch #{basic_path} --no-open").then (res) ->
      driver.get('http://localhost:1111')
        .then -> chai.expect('p').dom.to.have.text('hello worlds')
        .then ->
          sentinel = 0
          deferred = W.defer()

          res.project.once 'start', ->
            sentinel++
            # this happens too fast for selenium to reliably handle
            # chai.expect('#roots-compile-loader').dom.to.be.visible()

          res.project.once 'done', ->
            setTimeout ->
              chai.expect('p').dom.to.have.text('wow')
              sentinel.should.equal(1)
              fs.writeFileSync(path.join(basic_path, 'index.jade'), 'html\n  body\n    p= #$%#$T')
            , 500

          res.project.once 'error', ->
            setTimeout ->
              chai.expect('#roots-error').dom.to.be.visible()
              fs.writeFileSync(path.join(basic_path, 'index.jade'), 'html\n  body\n    p hello worlds')
              deferred.resolve()
            , 500

          fs.writeFileSync(path.join(basic_path, 'index.jade'), 'html\n  body\n    p wow')

          return deferred.promise
        .then -> res.server.close()
        .then -> done()
