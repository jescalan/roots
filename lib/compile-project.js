var colors = require('colors'),
    debug = require('./debug'),
    mkdirp = require('mkdirp'),
    readdirp = require('readdirp'),
    path = require('path'),
    fs = require('fs'),
    current_directory = path.normalize(process.cwd());

// -----------------------
// compile all the things!
// -----------------------

exports.compile_project = function(options, cb){

  process.stdout.write('\ncompiling project \n'.grey);

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
      require('../lib/compilers/' + file_type).compile(options, files[file_type], function(err) {
        if (!err) {
          next(counter, reload);
        } else {
          cb && cb(err);
        }
      });
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

  create_structure(views, function(files){
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

  create_structure(assets, function(files){
    compile_files(assets, files, true);
  });

  // These two could probably be compressed further with a minor refactor of the create_structure() method

};

// function: create structure
// --------------------------
// Reads through a directory, creates the necessary folders in public/, and
// feeds back a list of files that need to be compiled organized by extension

create_structure = function(options, cb){
  readdirp({ root: path.join(current_directory, options.folder) }, function(err, res){

    // create public (if not already made)
    mkdirp.sync(path.join(current_directory, 'public'));

    // create sub directories needed
    res.directories.forEach(function(dir){
      mkdirp.sync(path.join('public', dir.path));
    });

    // get and sort the files
    var files = {}
    res.files.forEach(function(file){ // loop through files in /assets
      options.file_types.forEach(function(type){ // loop through file types for detection
        if (file.path.match(new RegExp('\.' + type + '$'))){

          // logic for ignored files
          var skip = false;
          options.ignore_files.forEach(function(ignore){
            if (path.basename(file.path).match(ignore)){ skip = true; }
          });

          // add the file to the files list under the correct extension
          if (!skip) {
            if (typeof files[type] === 'undefined') { files[type] = []; }
            files[type].push(file.path);
          }

        }
      });
    });

    // hit the callback and pass the organized files object back
    cb(files);
  });
}