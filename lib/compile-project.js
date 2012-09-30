var colors = require('colors'),
    config = require('./compilers/config'),
    helpers = require('../lib/helpers');

// step through compile helper
var next = function(counter){
  var lang = counter.shift();
  config.debug('compiled '.grey + lang.grey);
  if (counter.length < 1) {
    config.debug('finished section\n'.green);
    if (typeof cb !== 'undefined'){ console.log('executed callback'); cb(); }
  }
}

// compile all the things!


exports.compile_project = function(options, cb){

  process.stdout.write('\ncompiling project... \n\n'.grey);

  // -------------------------------------------------------------------
  // view compilation (for some reason this seems to always happen first)
  // -------------------------------------------------------------------
  
  // set up options for view compilation

  var views = {};
  with (options) {
    views.file_types = file_types;
    views.ignore_files = ignore_files;
    views.folder = folder_config.views;
  }

  helpers.create_structure(views, function(files){

    formats = ['jade', 'haml', 'ejs'];
    counter = formats.slice(0);
    var step = function(){ next(counter); }

    formats.forEach(function(format){
      require('../lib/compilers/' + format).compile(views.folder, files[format], step);
    });

    // completion function

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

    formats = ['coffee', 'styl'];
    counter = formats.slice(0);
    var step = function(){ next(counter); }

    formats.forEach(function(format){
      require('../lib/compilers/' + format).compile(assets.folder, files[format], step);
    });

  });

};