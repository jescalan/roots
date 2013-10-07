var path = require('path'),
    config = require('../global_config'),
    analytics = require('../analytics');

var _pkg = function(args){

  var pkg_mgr = require(path.join('../package_managers', config.get().package_manager));
  pkg_mgr(args._.slice(1));

  analytics.track_command('pkg', args._);

};

module.exports = { execute: _pkg, needs_config: true };
