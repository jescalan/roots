var colors = require('colors'),
    debug = require('./debug'),
    mkdirp = require('mkdirp'),
    readdirp = require('readdirp'),
    path = require('path'),
    fs = require('fs'),
    rimraf = require('rimraf'),
    current_directory = path.normalize(process.cwd());

// -----------------------
// compile all the things!
// -----------------------

exports.compile_project = function(cb){

  var options = global.options;
  process.stdout.write('\ncompiling project \n'.grey);

  // function: next
  // --------------
  // helper function to keep track of what has been compiled and optionally
  // hit a callback once they are all finished.
  //
  //    - counter: (array) list of languages being compiled
  //    - reload: (boolean) whether to hit the callback or not

  // views and assets are compiled async, and when each finishes,
  // reload is bumped. the last one to finish will fire the reload
  // unless an error has occurred
  var reload = 0;
  var error = false;

  var next = function(counter){
    var lang = counter.shift();
    debug.log(lang.green + ' compiled'.green);
    if (counter.length < 1 ) {
      reload++;
      if (typeof cb !== 'undefined' && reload > 1 && !error){
        if (error) { 
          // stamp a flash message on every html file in public/
        }
        cb();
      }
    }
  };

  // function: compile files
  // -----------------------
  // compiles files in sequence and writes them to the public folder
  //
  //    - category: (object) configuration object (views or assets, examples below)
  //    - files: (array) a list of files to be compiled
  //    - reload: (boolean) whether or not to reload the page after compilation

  var compile_files = function(type, files){

    counter = type.file_types.slice(0);

    type.file_types.forEach(function(file_type){
      
      // assemble paths for possible compilers
      var core_compiler_path = path.join('../lib/compilers/core', file_type + '.js');
      var plugin_compiler_path = path.join(current_directory + '/vendor/plugins/' + file_type);

      // define the callback, used for either compiler
      var callback = function(err) {
        if (!err) { next(counter); } else {
          if (err) { console.log("\nERROR!\n\n".red + err); error = true; }
        }
      }

      // if there's a plugin, use it
      if (fs.existsSync(plugin_compiler_path + '.js') || fs.existsSync(plugin_compiler_path + '.coffee')) {
        require('coffee-script');
        var helper = require('./compilers/compile-helper')
        require(plugin_compiler_path).compile(files[file_type], global.options, helper, callback);
      }

      // if not, use the core compiler
      else if (fs.existsSync(core_compiler_path)) { 
        require(core_compiler_path).compile(files[file_type], callback);
      }

    });

  }

  // function: create structure
  // --------------------------
  // Reads through a directory, creates the necessary folders in public/, and
  // feeds back a list of files that need to be compiled organized by extension

  create_structure = function(custom_options, cb){
    readdirp({ root: path.join(current_directory, custom_options.folder) }, function(err, res){

      // create public (if not already made)
      mkdirp.sync(path.join(current_directory, 'public'));

      // create sub directories needed
      res.directories.forEach(function(dir){
        mkdirp.sync(path.join('public', dir.path));
      });

      // get and sort the files
      var files = {}
      res.files.forEach(function(file){ // loop through files in /assets
        custom_options.file_types.forEach(function(type){ // loop through file types for detection
          if (file.path.match(new RegExp('\.' + type + '$'))){

            // logic for ignored files
            var skip = false;
            custom_options.ignore_files.forEach(function(ignore){
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

  // get rid of the old project
  rimraf.sync(path.join(current_directory, 'public'));

  // -------------------------------------------------------------------
  // view compilation
  // -------------------------------------------------------------------

  var views = {
    file_types: options.file_types.html,
    ignore_files: options.ignore_files,
    folder: options.folder_config.views
  };

  create_structure(views, function(files){
    compile_files(views, files);
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
    compile_files(assets, files);
  });

  // -------------------------------------------------------------------
  // image compilation
  // -------------------------------------------------------------------

  var img_source = path.join(current_directory, options.folder_config.assets, 'img');
  var img_destination = path.join(current_directory, 'public/img');

  mkdirp.sync(img_destination);

  require('ncp').ncp(img_source, img_destination, function (err) {
    if (err) { return console.error(err); }
   // if (global.options.compress) { console.log('compressing images'); }
  });

};