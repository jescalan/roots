var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    _ = require('underscore'),
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
  roots.compile_project(function(){ server.start(current_directory); });

  // watch views/assets directories for changes and reload
  var directories = ["./" + global.options.folder_config.views, "./" + global.options.folder_config.assets];

  // now that the file is available, the next step is to only
  // compile the single file that was changed. being able to do
  // either a single file or the entire project without an ugly
  // codebase will be the mark of great design for roots.
  
  watcher.watchDirectories(directories, _.debounce(function(file){
    roots.compile_project(function() { server.reload(); });
  }, 500));

}

module.exports = { execute: _watch, needs_config: true }