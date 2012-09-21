var coffeescript = require('../lib/compilers/coffee'),
    stylus = require('../lib/compilers/stylus'),
    jade = require('../lib/compilers/jade'),
    haml = require('../lib/compilers/haml'),
    colors = require('colors'),
    helpers = require('../lib/helpers');

// compile all the things!

exports.compile_project = function(dir, file_types, ignore_files, cb){

  process.stdout.write('\ncompiling project... \n\n'.grey);

  // view compilation (for some reason this seems to always happen first)
  helpers.create_structure(dir.views, file_types, ignore_files, function(files){

    var complete = 0;

    jade.compile(dir.views, files.jade, function(){ complete++; });
    haml.compile(dir.views, files.haml, function(){ complete++; });
    helpers.pass_through(dir.views, files.html, function(){ complete++; });

    while (complete < 3) {}
    console.log('view compilation finished!\n'.green);
    if (typeof cb !== 'undefined'){ cb(); }

  });

  helpers.create_structure(dir.assets, file_types, ignore_files, function(files){

    var complete = 0;

    coffeescript.compile(dir.assets, files.coffee, function(){ complete++; } );
    helpers.pass_through(dir.assets, files.js, function(){ complete++; });

    stylus.compile(dir.assets, files.styl, function(){ complete++; });
    helpers.pass_through(dir.assets, files.css, function(){ complete++; });

    while (complete < 4) {}
    console.log('asset compilation finished!\n'.green);
    process.stdout.write('done!\n\n'.green);

  });

};