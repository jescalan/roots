var path = require('path'),
    current_directory = path.normalize(process.cwd()),
    fs = require('fs'),
    _ = require('underscore'),
    minimatch = require('minimatch'),
    output_path = require('../utils/output_path'),
    yaml_parser = require('../utils/yaml_parser'),
    watcher = require('../watcher'),
    roots = require('../index'),
    Compiler = require('../compiler'),
    server = require('../server'),
    colors = require('colors');

var compiler = new Compiler();

var _watch = function(){

  // add in the livereload function
  var socket_script = "<script>" + fs.readFileSync(path.join(__dirname, '../../templates/reload/reload.min.js'), 'utf8') + "</script>";
  var spinner_html = fs.readFileSync(path.join(__dirname, '../../templates/reload/spinner.html'));
  global.options.locals.livereload = socket_script + spinner_html;

  // compile once and run the local server when ready
  compiler.mode = 'dev';
  roots.compile_project(current_directory, function(){ server.start(current_directory); });

  // watch the project for changes and reload
  watcher.watch_directory(current_directory, _.debounce(watch_function, 500));

  function watch_function(file){

    server.compiling();

    // make sure the file wasn't deleted
    if (fs.existsSync(file.fullPath)){

      // if there was an error, the whole project needs to be recompiled to
      // get rid of the error message
      if (global.options.error) return compile_project('error');

      // if it's a dynamic file, the entire project needs to be recompiled
      // so that references to it show up in other files
      if (yaml_parser.detect(file.fullPath)) return compile_project('dynamic file')

      // ignored files that are modified are often dependencies
      // for another non-ignored file. Until we have an asset graph
      // in this project, the safest approach is to recompile the
      // whole project when an ignored file is modified.
      var ignored = global.options.ignore_files;

      for (var i = 0; i < ignored.length; i++){
        if (minimatch(path.basename(file.path), ignored[i].slice(1))) {
          options.debug.log('ignored file changed, reloading project')
          return roots.compile_project(current_directory, server.reload);
        }
      }

      compile_single_file(file.fullPath);
    } else {
      // if the changed file was deleted, just remove it in the public folder
      try {
        fs.unlinkSync(output_path(file.fullPath));
      } catch(e) {
        console.log("Error Unlinking File".inverse.red);
        console.log(e);
      }
      server.reload();
    }
  }

};

module.exports = { execute: _watch, needs_config: true };

function compile_single_file(file_path){
  options.debug.log('single file compile');
  roots.compile_project(file_path, server.reload);
}

function compile_project(reason){
  options.debug.log(reason + ": full project compile");
  global.options.error = false;
  return roots.compile_project(current_directory, server.reload);
}
