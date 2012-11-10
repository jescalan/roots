require('coffee-script');

var path = require('path'),
    get_compiler = require('./get_compiler'),
    fs = require('fs');

// note: this is only passed the file types, not the whole options
// object. when implemented, the compiler names also shouldn't matter

module.exports = function(file_types, files, next){
  var counter = file_types.slice(0);
  var error = false;

  file_types.forEach(function(file_type){

    // get everything we need to pass to the compiler
    var Helper = require('../compilers/compile-helper');
    var compiler = get_compiler(file_type);

    // pull in dependencies if there are any (really would only happen
    // for a plugin)

    // for (key in compiler.dependencies) {
    //   find some way to require the dependency
    //   inside the compiler as var key = require(path.join(current_directory, compiler.dependencies[key]))
    // }

    // move on if there are no files of the specified type
    if (files[file_type] == undefined ) { return next(counter) }

    // compile the files, call next when finished and pass error if exists
    compiler.compile(files[file_type], Helper, function(err) {
      if (err) { console.log("compile error\n".red + err); error = err; }
      next(counter, error);
    });

  });

}

// I still think something is wrong about this. I've already looped through
// all the compilers during project setup, this shouldn't have to happen again.
// This will probably get refactored again in phase 2, but this is a start