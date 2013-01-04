var fs = require('fs'),
    path = require('path'),
    colors = require('colors');

require('coffee-script');

module.exports = function(cb){

  if (!fs.existsSync(path.join(process.cwd() + '/app.coffee'))) {

    console.error("\nnot a roots project - run `roots help` if you are confused\n".yellow);

  } else {

    // pull the app config file
    var options = global.options = require(path.join(process.cwd() + '/app.coffee'));

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

    // i'm honestly the only one that uses this, removed from app config default.
    options.debug = {
      status: false,
      log: function(data){ if (this.status) { console.log(data.grey); } }
    }

    cb();

  }
}