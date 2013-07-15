path = require("path")
config = require("../global_config")
_pkg = (args) ->
  pkg_mgr = require(path.join("../package_managers", config.get().package_manager))
  pkg_mgr args._.slice(1)

module.exports =
  execute: _pkg
  needs_config: true
