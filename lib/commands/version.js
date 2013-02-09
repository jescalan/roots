var fs = require('fs');
var path = require('path');

var _version = function(){
  var version = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'))).version;
  console.log(version);
};

module.exports = { execute: _version };
