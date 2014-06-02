Roots   = require("../../")
When    = require("when")
path    = require("path").resolve(__dirname, 'rage')
rimraf  = require("rimraf")
Server = require("../../lib/local_server")

on_error = (cli, server, err) -> server.show_error(Error(err).stack)
on_start = (cli, server) -> server.compiling()
on_done = (cli, server) -> server.reload()

module.exports = ->
  @After ->
    When.Promise (resolve) ->
      rimraf path,  ->
        console.log arguments
        resolve()

  @Given /^I have a roots project$/, ->
    Roots.new(
      path: path
      overrides:
        name: "doge-hunter"
        description: "data love geordi"
    )

  @Given /^I am watching it$/, ->
    _this = this

    When.Promise (resolve) ->
      project = new Roots(path)
      server  = new Server(project, project.root)
      watcher = project.watch()
      cli     = {}

      server.start(1111)

      watcher.then ->
        _this.driver.get("http://127.0.0.1:1111/").then -> resolve()
