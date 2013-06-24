var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    server = require('../server');

var _serve = function(){
  server.start(current_directory);
};

module.exports = { execute: _serve };
