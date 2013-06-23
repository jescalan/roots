var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    server = require('../server'),
    colors = require('colors');

var _serve = function(){
  server.start(current_directory);
};

module.exports = { execute: _serve };
