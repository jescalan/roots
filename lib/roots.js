var colors = require('colors'),
    debug = require('./debug'),
    utils = require('./utils'),
    async = require('async'),
    compiler = require('./utils/compiler');

exports.compile_project = function(cb){

  // handle compile errors
  
  compiler.on('error', function(){
    utils.add_error_messages();
    this.finish();
  });

  // callback for compile process
  
  compiler.one('finished', function(){
    console.log('compile finished');
    cb();
  });

  // the (rather complex) compile process
  // tried to make the code as clear as possible, email me with questions
  // if you are confused and/or looking to contribute!
  
  utils.analyze_project().then(create_folders).then(function(structure){

    async.parallel([compile_files, copy_static_files], compiler.finish);

    function compile_files(cb){
      async.map(structure.compiled_files, compiler.compile, cb)
    }

    function copy_static_files(cb){
      for (var key in structure.static_files) {
        utils.copy_sync({ src: structure.static_files[key], dest: opts.folder })
      }
    }

  });

  function create_folders(structure){
    for (var key in structure.folders) {
      mkdir.sync(structure.folders[key])
    }
    return structure
  }

};