var colors = require('colors'),
    debug = require('./debug'),
    helpers = require('../lib/helpers');

// compile all the things!

exports.compile_project = function(options, cb){

  process.stdout.write('\ncompiling project... \n\n'.grey);

  // step through: compile helper
  var next = function(counter, load){
    var lang = counter.shift();
    debug.log(lang.green + ' compiled'.green);
    if (counter.length < 1 && load) {
      console.log('\nreloading page\n'.red);
      if (typeof cb !== 'undefined'){ cb(); }
    }
  };

  // -------------------------------------------------------------------
  // view compilation
  // -------------------------------------------------------------------
  
  // set up options for view compilation

  var views = {};
  with (options) {
    views.file_types = file_types;
    views.ignore_files = ignore_files;
    views.folder = folder_config.views;
  }

  helpers.create_structure(views, function(files){

    formats = ['jade', 'haml', 'ejs', 'html']; // this should pull from file types
    counter = formats.slice(0);

    formats.forEach(function(format){
      require('../lib/compilers/' + format).compile(views.folder, files[format], function(){ next(counter, false); });
    });

  });

  // -------------------------------------------------------------------
  // asset compilation
  // -------------------------------------------------------------------
  
  var assets = {};
  with (options) {
    assets.file_types = file_types;
    assets.ignore_files = ignore_files;
    assets.folder = folder_config.assets;
  }

  helpers.create_structure(assets, function(files){

    formats = ['coffee', 'js', 'styl', 'css'];
    counter = formats.slice(0);

    formats.forEach(function(format){
      require('../lib/compilers/' + format).compile(assets.folder, files[format], function(){ next(counter, true); });
    });

  });

};