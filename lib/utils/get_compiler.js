require('coffee-script');

var path = require('path'),
    shell = require('shellks'),
    compilers = require('../compilers').all();

var plugin_path = path.join(process.cwd() + '/plugins'),
    plugins = shell.ls(plugin_path);

// given a file type, returns that file type's compiler
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