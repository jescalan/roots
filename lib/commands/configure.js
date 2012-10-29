var fs = require('fs'),
    path = require('path'),
    debug = require('../debug'),
    colors = require('colors'),
    current_directory = path.normalize(process.cwd());

require('coffee-script');

var configure = function(cb){

  // pull the app config file, compiled with coffeescript
  var options = global.options = require(current_directory + '/app.coffee');

  // go through compilers and figure out which file extensions we need to
  // compile for this project
  options.file_types = {}
  core_compilers_path = path.join(__dirname, '../compilers/core');
  plugins_path = path.join(current_directory + '/vendor/plugins');

  var parse_filetypes = function(compiler_path){
    fs.readdirSync(compiler_path).forEach(function(file){
      var compiler = require(path.join(compiler_path, file)).settings
      if (options.file_types[compiler.target] == undefined) { options.file_types[compiler.target] = [] }
      options.file_types[compiler.target].push(compiler.file_type);
    });
  }

  // add all core compilers and plugins, if there are any
  parse_filetypes(core_compilers_path);

  // this is total junk and needs to change
  if (fs.existsSync(plugins_path) && fs.readdirSync(plugins_path).length > 1) { parse_filetypes(plugins_path); }

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
    console.log("\nnot a roots project - run `roots help` if you are confused\n".yellow);
  }
}