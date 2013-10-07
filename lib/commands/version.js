var fs = require('fs'),
    roots = require('../index'),
    path = require('path'),
    analytics = require('../analytics');

var _version = function(){
  var version = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'))).version;
  roots.print.log(version);
  analytics.track_command('version');
};

module.exports = { execute: _version };
