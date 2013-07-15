fs = require("fs")
path = require("path")
_version = ->
  version = JSON.parse(fs.readFileSync(path.join(__dirname, "../../package.json"))).version
  console.log version

module.exports = execute: _version
