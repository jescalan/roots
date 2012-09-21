var coffeescript = require('../lib/compilers/coffee'),
    stylus = require('../lib/compilers/stylus'),
    jade = require('../lib/compilers/jade'),
    haml = require('../lib/compilers/haml'),
    colors = require('colors'),
    helpers = require('../lib/helpers');

// compile all the things!

exports.compile_project = function(dir, file_types, ignore_files){

  process.stdout.write('\ncompiling project... '.grey);

  helpers.create_structure(dir.assets, file_types, ignore_files, function(files){

    // these are NOT sync, need callbacks

    coffeescript.compile(dir.assets, files.coffee);
    helpers.pass_through(dir.assets, files.js);

    stylus.compile(dir.assets, files.styl);
    helpers.pass_through(dir.assets, files.css);

  });

  // view compilation
  helpers.create_structure(dir.views, file_types, ignore_files, function(files){

    // these are NOT sync, need callbacks

    jade.compile(dir.views, files.jade);
    haml.compile(dir.views, files.haml);
    helpers.pass_through(dir.views, files.html);

  });

   process.stdout.write('done!\n\n'.green);

};