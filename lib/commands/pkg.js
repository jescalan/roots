var path = require('path'),
    config = require('../global_config'),
    shell = require('shelljs');

var _pkg = function(command){

  var pkg_mgr = require(path.join('../package_managers', config.get().package_manager));
  pkg_mgr(command);

};

module.exports = { execute: _pkg, needs_config: true };
