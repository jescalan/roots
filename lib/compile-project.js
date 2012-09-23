var coffeescript = require('../lib/compilers/coffee'),
    stylus = require('../lib/compilers/stylus'),
    colors = require('colors'),
    config = require('./compilers/config'),
    helpers = require('../lib/helpers'),
    markup_formats = require('../lib/markup-formats');

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

  helpers.create_structure(views, function(files) {
    compile_formats = markup_formats.get_formats(files);
    compile_formats.forEach(function loop_through_each_format(val, index) {
      val.func(views.folder, val.files, function() {compile_step(cb, index, compile_formats.length - 1)});
    });
  });

  // after each format compiles increment count until
  // it hits finished_count and then run optional CB
  function compile_step(cb, count, finished_count) {
    ++count == finished_count && function front_end_compile_finished() {
      config.debug('view compilation finished!\n'.green);
      cb && cb();
    }();
  }

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
    config.debug('asset compilation finished!\n'.green);
    process.stdout.write('done!\n\n'.green);

  });

};