var fs = require('fs'),
    js_yaml = require('js-yaml'),
    path = require('path');

// matches multiline yaml front matter
var matcher = exports.matcher = /^---\s*\n([\s\S]*?)\n?---\s*\n?/;

// matchs front matter from a given string
var match = exports.match = function(content){
  return content.match(matcher);
}

// parse yaml from any string of content and return a
// javascript object or false if it could not be parsed
var parse = exports.parse = function(content, options){
  if (typeof options === 'undefined') { var options = {}; }
  var front_matter = match(content);
  if (!front_matter) { return false };
  return js_yaml.safeLoad(front_matter[1], options);
}

// given a file, returns a boolean indicating whether
// that file has yaml front matter or not
exports.detect = function(file){
  if (path.extname(file) !== '.jade') { return false }

  var contents = fs.readFileSync(file, 'utf8');
  if (match(contents)){ return true };
  return false
}
