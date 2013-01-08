var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    _ = require('underscore'),
    minimatch = require('minimatch'),
    output_path = require('../utils/output_path'),
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

  // watch the project for changes and reload
  watcher.watch_directory(current_directory, _.debounce(watch_function, 500));

  function watch_function(file){

    // ignored files that are modified actively are often dependencies
    // for another non-ignored file. Until we have something like assetgraph
    // in this project, the safest approach is to recompile the whole project
    // when an ignored file is modified.
    
    var ignored = global.options.ignore_files;

    for (var i = 0; i < ignored.length; i++){
      if (!minimatch(file.path, ignored[i])) {
        return roots.compile_project(current_directory, server.reload);
      }
    }

    if (fs.existsSync(file.fullPath)){
      roots.compile_project(file.fullPath, server.reload);
    } else {
      fs.unlinkSync(output_path(file.fullPath));
      server.reload();
    }
  }

}

module.exports = { execute: _watch, needs_config: true }