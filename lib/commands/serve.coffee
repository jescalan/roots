path = require("path")
roots = require("../index")
current_directory = path.normalize(roots.project.rootDir)
server = require("../server")
_serve = ->
  server.start current_directory

module.exports = execute: _serve
