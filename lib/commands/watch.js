var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    _ = require('underscore'),
    shell
    watcher = require('../watcher'),
    roots = require('../roots'),
    Compiler = require('../compiler'),
    server = require('../server'),
    colors = require('colors');

// @api private
var compiler = new Compiler();

var _watch = function(){

  // add in the livereload function
  global.options.locals.livereload = "<script>" + fs.readFileSync(path.join(__dirname, '../../templates/reload/reload.min.js'), 'utf8') + "</script>"

  // compile once and run the local server when ready
  roots.compile_project(current_directory, function(){ server.start(current_directory); });

  // watch views/assets directories for changes and reload
  var directories = ["./" + global.options.folder_config.views, "./" + global.options.folder_config.assets];
  
  watcher.watchDirectories(directories, _.debounce(function(file){
    if (fs.existsSync(file.fullPath)){
      roots.compile_project(file.fullPath, function() { server.reload(); });
    } else {
      fs.unlinkSync(output_path(file.fullPath));
      server.reload();
    }
  }, 500));

}

module.exports = { execute: _watch, needs_config: true }