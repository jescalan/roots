var path = require('path'),
    server = require('../server'),
    roots = require('../index'),
    analytics = require('../analytics');

var _serve = function(){
  server.start(roots.project.rootDir);
  analytics.track_command('serve');
};

module.exports = { execute: _serve };
