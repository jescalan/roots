var fs = require('fs'),
    path = require('path'),
    debug = require('../debug'),
    colors = require('colors'),
    wrench = require('wrench'),
    util = require('util'),
    current_directory = path.normalize(process.cwd());

require('coffee-script');

var configure = function(cb){

  // TODO: this piece needs a major refactor after phase 2 refactor is implemented

  // pull the app config file, compiled with coffeescript
  var options = global.options = require(current_directory + '/app.coffee');

  // go through compilers and figure out which file extensions we need to
  // compile for this project
  options.file_types = {}
  core_compilers_path = path.join(__dirname, '../compilers/core');
  plugins_path = path.join(current_directory + '/plugins');

  var parse_filetypes = function(compiler_path){
    fs.existsSync(compiler_path) && wrench.readdirSyncRecursive(compiler_path).forEach(function(file){
      if (file.match(/.*\.[js|coffee]+$/)) {
        var compiler = require(path.join(compiler_path, file))

        if (compiler.settings) {
          if (options.file_types[compiler.settings.target] == undefined) { options.file_types[compiler.settings.target] = [] }
          options.file_types[compiler.settings.target].push(compiler.settings.file_type);
        }
      }
    });
  }

  // manually set these for now. don't see why they would need
  // to be changed, but if so, it should be easy
  options.folder_config = {};
  options.folder_config.views = 'views';
  options.folder_config.assets = 'assets';

  // add all core compilers and plugins, if there are any
  parse_filetypes(core_compilers_path);

  // this is total junk and needs to change
  parse_filetypes(plugins_path);

  // make sure all layout files are ignored
  for (var key in options.layouts){
    options.ignore_files.push(new RegExp(options.layouts[key]));
  }

  // set the debug flag
  debug.set_debug(options.debug);

  // livereload function won't render anything unless in watch mode
  options.locals.livereload = "";

  cb();

}

module.exports = function(cb){
  if (fs.existsSync(current_directory + '/app.coffee')) {
    configure(cb)
  } else {
    console.error("\nnot a roots project - run `roots help` if you are confused\n".yellow);
  }
}