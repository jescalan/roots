var colors = require('colors'),
    debug = require('./debug'),
    helpers = require('../lib/helpers'); // this probably doesn't need to be in another file

// compile all the things!

exports.compile_project = function(options, cb){

  process.stdout.write('\ncompiling project... \n\n'.grey);

  // function: next
  // --------------
  // helper function to keep track of what has been compiled and optionally
  // hit a callback once they are all finished.
  // 
  //    - counter: (array) list of languages being compiled
  //    - reload: (boolean) whether to hit the callback or not

  var next = function(counter, reload){
    var lang = counter.shift();
    debug.log(lang.green + ' compiled'.green);
    if (counter.length < 1 && reload) {
      if (typeof cb !== 'undefined'){ cb(); }
    }
  };

  // function: compile files
  // -----------------------
  // compiles files in sequence and writes them to the public folder
  // 
  //    - category: (object) configuration object (views or assets, examples below)
  //    - files: (array) a list of files to be compiled
  //    - reload: (boolean) whether or not to reload the page after compilation

  var compile_files = function(type, files, reload){

    counter = type.file_types.slice(0);

    type.file_types.forEach(function(file_type){
      require('../lib/compilers/' + file_type).compile(options, files[file_type], function(){ next(counter, reload); });
    });

  }

  // -------------------------------------------------------------------
  // view compilation
  // -------------------------------------------------------------------
  
  var views = {
    file_types: options.file_types.html,
    ignore_files: options.ignore_files,
    folder: options.folder_config.views
  };

  helpers.create_structure(views, function(files){
    compile_files(views, files, false);
  });

  // -------------------------------------------------------------------
  // asset compilation
  // -------------------------------------------------------------------
  
  var assets = {
    file_types: options.file_types.css.concat(options.file_types.js),
    ignore_files: options.ignore_files,
    folder: options.folder_config.assets
  };

  helpers.create_structure(assets, function(files){
    compile_files(assets, files, true);
  });

  // These two could probably be compressed further with a minor refactor of the create_structure() method

};