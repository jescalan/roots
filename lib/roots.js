var colors = require('colors'),
    async = require('async'),
    shell = require('shelljs'),
    fs = require('fs'),
    path = require('path'),
    Q = require('q'),
    utils = require('./utils'),
    Compiler = require('./compiler');

exports.compile_project = function(cb){

  process.stdout.write('compiling... '.grey)
  global.options.debug.log('')

  var compiler = new Compiler();

  // handle compile errors
  compiler.on('error', function(err){
    var self = this;
    console.error(err.red);
    utils.add_error_messages(err, function(){ self.finish(); });
  });

  // callback for compilation process
  compiler.once('finished', function(){
    process.stdout.write('done!\n'.green)
    cb();
  });

  compiler.on('test', function(){
    console.log('hit testing event')
  });

  // the (rather complex) compile process
  // tried to make the code as clear as possible, email me with questions
  // if you are confused and/or looking to contribute!
  utils.analyze_project().then(create_folders).then(function(project){

    global.options.debug.log('compiling and copying files');

    // i know understand why this needs to be wrapped...
    async.parallel([compile_files, copy_static_files], function(){
      compiler.finish();
    });

    // the fact that i need to wrap it like this is ridiculous
    // there has to be a better way to deal with this situation...
    // i think the solution is a function that uses `call()`
    function compile_files(cb){
      async.map(project.compiled_files, function(a,b){ compiler.compile(a,b) }, cb);
    }

    function copy_static_files(cb){
      async.map(project.static_files, compiler.copy, cb);
    }

  });

  function create_folders(project){
    global.options.debug.log('creating folders');
    shell.mkdir('-p', path.join(process.cwd(), 'public'));

    for (var key in project.folders) {
      // both assets and views dump their contents to the public root
      var folder = project.folders[key].replace(/^assets|views/, '');
      shell.mkdir('-p', path.join(process.cwd(), 'public', folder));
    }

    return Q.fcall(function(){ return project });
  }

};