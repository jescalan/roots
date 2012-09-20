var coffeescript = require('../lib/compilers/coffee'),
    stylus = require('../lib/compilers/stylus'),
    jade = require('../lib/compilers/jade'),
    haml = require('../lib/compilers/haml'),
    helpers = require('../lib/helpers');

exports.compile_project = function(dir, file_types, ignore_files){

  helpers.create_structure(dir.assets, file_types, ignore_files, function(files){

    coffeescript.compile(dir.assets, files.coffee);
    helpers.pass_through(dir.assets, files.js);

    stylus.compile(dir.assets, files.styl);
    helpers.pass_through(dir.assets, files.css);

  });

  // view compilation
  helpers.create_structure(dir.views, file_types, ignore_files, function(files){

    jade.compile(dir.views, files.jade);
    haml.compile(dir.views, files.haml);
    helpers.pass_through(dir.views, files.html);

  });

};