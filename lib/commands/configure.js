var fs = require('fs'),
    colors = require('colors');

require('coffee-script');

var configure = function(cb){

  // pull the app config file
  var options = global.options = require(process.cwd() + '/app.coffee');

  // convention over configuration
  options.folder_config = {};
  options.folder_config.views = 'views';
  options.folder_config.assets = 'assets';

  // make sure all layout files are ignored
  for (var key in options.layouts){
    options.ignore_files.push(new RegExp(options.layouts[key]));
  }

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