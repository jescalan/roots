var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    watcher = require('../watcher'),
    roots = require('../roots'),
    server = require('../server'),
    colors = require('colors');

var _watch = function(){

  // D-BUG
  console.log('watch command executing');

  // add in the livereload function
  global.options.locals.livereload = "<script>" + fs.readFileSync(path.join(__dirname, '../../templates/reload/reload.min.js'), 'utf8') + "</script>"

  // compile once and run the local server when ready
  roots.compile_project(function(){ server.start(current_directory); });

  // watch the directory for changes and reload
  watcher.watchDirectories(["./" + global.options.folder_config.views, "./" + global.options.folder_config.assets], function(file) {
    roots.compile_project(function() { server.reload(); });
  });

}

module.exports = { execute: _watch, needs_config: true }