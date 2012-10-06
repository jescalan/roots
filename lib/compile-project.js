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
      console.log('\nreloading page\n'.red);
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

  var compile_files = function(category, files, reload){
    // this REEEALLY needs to be refactored - possibly passing the options object right through
    // to compile() would help, with an argument specifying whether it's views or assets

    counter = category.file_types.slice(0);

    category.file_types.forEach(function(format){
      require('../lib/compilers/' + format).compile(category.folder, files[format], category.layouts, function(){ next(counter, reload); });
    });

  }

  // -------------------------------------------------------------------
  // view compilation
  // -------------------------------------------------------------------
  
  var views = {
    file_types: options.view_file_types,
    ignore_files: options.ignore_files,
    folder: options.folder_config.views,
    layouts: options.layouts
  };

  helpers.create_structure(views, function(files){
    compile_files(views, files, false);
  });

  // -------------------------------------------------------------------
  // asset compilation
  // -------------------------------------------------------------------
  
  var assets = {
    file_types: options.asset_file_types,
    ignore_files: options.ignore_files,
    folder: options.folder_config.assets,
    layouts: null // this is unforgiveable, I understand. Soon to be refactored
  };

  helpers.create_structure(assets, function(files){
    compile_files(assets, files, true);
  });

  // NOTE: These two probably could be even further compressed - a lot of this
  // is repeated...

};