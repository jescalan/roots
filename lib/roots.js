var colors = require('colors'),
    async = require('async'),
    shell = require('shelljs'),
    debug = require('./debug'),
    utils = require('./utils'),
    Compiler = utils.compiler;

exports.compile_project = function(cb){

  var compiler = new Compiler();

  // handle compile errors
  compiler.on('error', function(err){
    utils.add_error_messages(err, function(){ this.finish(); });
  });

  // callback for compilation process
  compiler.once('finished', function(){
    console.log('compile finished');
    cb();
  });

  // the (rather complex) compile process
  // tried to make the code as clear as possible, email me with questions
  // if you are confused and/or looking to contribute!
  utils.analyze_project().then(create_folders).then(function(project){

    async.parallel([compile_files, copy_static_files], compiler.finish);

    function compile_files(cb){
      async.map(project.compiled_files, compiler.compile, cb)
    }

    function copy_static_files(cb){
      async.map(project.static_files, compiler.copy, cb)
    }

  });

  function create_folders(project){
    shell.mkdir('-p', path.join(process.cwd(), 'public'));

    for (var key in project.folders) {
      shell.mkdir(project.folders[key])
    }

    return project
  }

};