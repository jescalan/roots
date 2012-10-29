var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    watcher = require('../watcher'),
    roots = require('../roots'),
    server = require('../server'),
    colors = require('colors');

var _watch = function(){

  // add in the livereload function
  global.options.locals.livereload = "<script>" + fs.readFileSync(path.join(__dirname, '../reload.js'), 'utf8') + "</script>"

  // compile once
  roots.compile_project(function(){ server.reload(); });

  // run the local server
  server.start(current_directory);

  // watch the directory for changes and reload
  watcher.watchDirectories(["./" + global.options.folder_config.views, "./" + global.options.folder_config.assets], function() {
    roots.compile_project(function() {
      console.log('\nreloading page'.red); server.reload();
    });
  });

}

module.exports = { execute: _watch, needs_config: true }