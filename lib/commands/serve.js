var path = require('path'),
    server = require('../server'),
    roots = require('../index');

var _serve = function(){
  server.start(roots.project.rootDir);
};

module.exports = { execute: _serve };
