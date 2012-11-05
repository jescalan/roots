require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

module.exports = function(file_type){
  result = false;

  // look in core first
  require('../compilers').all().forEach(function(compiler){
    if (compiler.settings.file_type == file_type) { result = compiler; }
  });

  // then look in the plugins folder
  var plugin_path = path.join(current_directory + '/plugins');

  // need to get a readdirp sync here
  fs.existsSync(plugin_path) && fs.readdirSync(plugin_path).forEach(function(file){
    var compiler = require(path.join(plugin_path, file));
    if (compiler.settings && compiler.settings.file_type == file_type) { result = compiler; }
  });

  return result
}