var colors = require('colors'),
    debug = require('./debug'),
    path = require('path'),
    utils = require('./utils');

// -----------------------
// compile all the things!
// -----------------------

exports.compile_project = function(cb){

  // -------------------------------------------------------------------
  // Async Management
  // -------------------------------------------------------------------

  // Since the compiling process is completely async, this guy keeps track
  // of what has been compiled and what has not, as well as when an error
  // comes up in any of the comple processes. It adds errors as flash
  // messages if they are present, and hits the callback when all the files
  // are done compiling.

  // This really needs a refactor, but is super tough because of the async
  // nature of everything and the density of logic in here. Will happen in
  // phase 3 refactoring.

  var reload = 0;
  var error = false;

  var next = function(counter, compile_error){
    var lang = counter.shift();
    debug.log(lang.green + ' compiled'.green);

    if (compile_error) { error = compile_error }

    if (counter.length < 1 ) {
      reload++;
      if (typeof cb !== 'undefined' && reload > 1) {
        if (error) {
          utils.add_error_messages(error, function(){ cb(); });
        } else {
          process.stdout.write('done!'.green);
          cb();
        }
      }
    }

  };

  process.stdout.write('\ncompiling project...'.grey);

  // -------------------------------------------------------------------
  // view compilation
  // -------------------------------------------------------------------

  var views = {
    file_types:   global.options.file_types.html,
    ignore_files: global.options.ignore_files,
    folder:       global.options.folder_config.views
  };

  utils.create_structure(views, function(files){
    utils.compile_files(views.file_types, files, next);
  });

  // -------------------------------------------------------------------
  // asset compilation
  // -------------------------------------------------------------------

  var assets = {
    file_types:   global.options.file_types.css.concat(global.options.file_types.js),
    ignore_files: global.options.ignore_files,
    folder:       global.options.folder_config.assets
  };

  utils.create_structure(assets, function(files){
    utils.compile_files(assets.file_types, files, next);
  });

  // -------------------------------------------------------------------
  // image compilation
  // -------------------------------------------------------------------

  var img_source = path.join(current_directory, global.options.folder_config.assets, 'img');
  var img_destination = path.join(current_directory, 'public/img');

  utils.process_images(img_source, img_destination)

};