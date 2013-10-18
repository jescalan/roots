var path = require('path'),
    fs = require('fs'),
    _ = require('underscore'),
    minimatch = require('minimatch'),
    output_path = require('../utils/output_path'),
    yaml_parser = require('../utils/yaml_parser'),
    watcher = require('../watcher'),
    roots = require('../index'),
    colors = require('colors');

roots.server = require('../server');
_.bindAll(roots.print, 'reload');

var _watch = function(){

  roots.print.compiling();

  // compile once and run the local server when ready
  roots.project.mode = 'dev';
  roots.compile_project(roots.project.rootDir, function(){
    roots.print.reload();
    roots.server.start(roots.project.path('public'));
    roots.browserPrinter = new roots.printers.BrowserPrinter(); // @private
  });

  // watch the project for changes and reload
  watcher.watch_directory(roots.project.rootDir, _.debounce(watch_function, 500));

  function watch_function(file){
    roots.print.compiling();

    // make sure the file wasn't deleted
    if (fs.existsSync(file.fullPath)){
      // if it's a dynamic file, the entire project needs to be recompiled
      // so that references to it show up in other files
      if (yaml_parser.detect(file.fullPath)) return compile_project('dynamic file');

      // ignored files that are modified are often dependencies
      // for another non-ignored file. Until we have an asset graph
      // in this project, the safest approach is to recompile the
      // whole project when an ignored file is modified.
      var ignored = global.options.ignore_files;

      for (var i = 0; i < ignored.length; i++){
        if (minimatch(path.basename(file.path), ignored[i].slice(1))) {
          return compile_project('ignored file changed')
        }
      }
      compile_single_file(file.fullPath);
    } else {
      // if the changed file was deleted, just remove it in the public folder
      try {
        fs.unlinkSync(output_path(file.fullPath));
      } catch(e) {
        roots.print.log("Error Unlinking File".inverse, 'red');
        roots.print.error(e);
      }
    }
  }
};

module.exports = { execute: _watch, needs_config: true };

function compile_single_file(file_path){
  roots.print.debug('single file compile');
  roots.compile_project(file_path, roots.print.reload);
}

function compile_project(reason){
  roots.project.locals.site = {} // clear out site locals between reloads
  roots.print.debug(reason + ": full project compile");
  return roots.compile_project(roots.project.rootDir, roots.print.reload);
}
