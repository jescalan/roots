var path = require('path'),
    roots = require('../index'),
    current_directory = path.normalize(roots.project.root_dir),
    server = require('../server');

var _serve = function(){
  server.start(current_directory);
};

module.exports = { execute: _serve };
