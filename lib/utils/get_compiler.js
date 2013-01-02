require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    wrench = require('wrench'),
    util = require('util'),
    compilers = require('../compilers').all(),
    current_directory = path.normalize(process.cwd());

var plugin_path = path.join(current_directory + '/plugins'),
    plugins = fs.existsSync(plugin_path) && wrench.readdirSyncRecursive(plugin_path);

module.exports = function(file_type){

  // look in core first
  for (var i = 0; i < compilers.length; i++) {
    if (compiler.settings.file_type == file_type) { return compiler; }
  }

  // then look in plugins
  for (var i = 0; i < plugins.length; i++) {
    if (file.match(/.*\.[js|coffee]+$/)) {
      var compiler = require(path.join(plugin_path, file));
      if (compiler.settings && compiler.settings.file_type == file_type) { return compiler; }
    }
  }

  // if all else fails...
  return false

}