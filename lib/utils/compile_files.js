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

    // compile the files, call next when finished and pass error if exists
    // TODO: only do this is there are files of the specified file type
    compiler.compile(files[file_type], Helper, function(err) {
      if (err) { console.log("compile error\n".red + err); error = err; }
      next(counter, error);
    });

  });

}

// I still think something is wrong about this. I've already looped through
// all the compilers during project setup, this shouldn't have to happen again.
// This will probably get refactored again in phase 2, but this is a start