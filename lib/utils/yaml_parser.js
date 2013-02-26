var fs = require('fs'),
    path = require('path');

var matcher = exports.matcher = /^---\s*\n([\s\S]*?)\n?---\s*\n?/;

exports.detect = function(file){
  if (path.extname(file) !== '.jade') { return false }

  var contents = fs.readFileSync(file, 'utf8');
  if (contents.match(matcher)){ return true };
  return false
}