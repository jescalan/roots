var coffeescript = require('../lib/compilers/coffee'),
    stylus = require('../lib/compilers/stylus'),
    jade = require('../lib/compilers/jade'),
    haml = require('../lib/compilers/haml'),
    ejs = require('../lib/compilers/ejs'),
    colors = require('colors'),
    helpers = require('../lib/helpers');

// compile all the things!

// TODO: some sort of debug flag that logs as files are compiled
// and can be turned off. currently logs by default while in development

exports.compile_project = function(options, cb){

  process.stdout.write('\ncompiling project... \n\n'.grey);

  // -------------------------------------------------------------------
  // view compilation (for some reason this seems to always happen first)
  // -------------------------------------------------------------------
  
  // set up options for view compilation

  var views = {};
  with (options) { // props to jresig for teaching me about with
    views.file_types = file_types;
    views.ignore_files = ignore_files;
    views.folder = folder_config.views;
    // in here will be locals and layout things as well
  }

  // make it happen

  helpers.create_structure(views, function(files){

    var complete = 0;

    jade.compile(views.folder, files.jade, function(){ complete++; });
    haml.compile(views.folder, files.haml, function(){ complete++; }); // might actually remove this
    ejs.compile(views.folder, files.ejs, function(){ complete++; });
    helpers.pass_through(views.folder, files.html, function(){ complete++; });

    while (complete < 4) {}
    // blocks flow until compilation has finished. could be more elegant
    // https://github.com/kriszyp/node-promise
    console.log('view compilation finished!\n'.green);
    if (typeof cb !== 'undefined'){ cb(); }

  });

  // -------------------------------------------------------------------
  // asset compilation
  // -------------------------------------------------------------------
  
  // set up asset compilation options
  
  var assets = {};
  with (options) {
    assets.file_types = file_types;
    assets.ignore_files = ignore_files;
    assets.folder = folder_config.assets;
    // could possibly put custom css functions here
  }

  helpers.create_structure(assets, function(files){

    var complete = 0;

    coffeescript.compile(assets.folder, files.coffee, function(){ complete++; } );
    helpers.pass_through(assets.folder, files.js, function(){ complete++; });

    stylus.compile(assets.folder, files.styl, function(){ complete++; });
    helpers.pass_through(assets.folder, files.css, function(){ complete++; });

    while (complete < 4) {}
    console.log('asset compilation finished!\n'.green);
    process.stdout.write('done!\n\n'.green);

  });

};