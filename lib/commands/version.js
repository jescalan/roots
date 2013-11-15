var fs = require('fs'),
    roots = require('../index'),
    path = require('path');

var _version = function(){
  var version = require(path.join(__dirname, '../../package.json')).version;
  roots.print.log(version);
};

module.exports = { execute: _version };
