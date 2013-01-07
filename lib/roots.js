var colors = require('colors'),
    async = require('async'),
    shell = require('shelljs'),
    path = require('path'),
    Q = require('q'),
    utils = require('./utils'),
    _ = require('underscore'),
    Compiler = require('./compiler');

// rather than being compile project, this should just be
// compile. it should be able to take anything from a single
// file to a large nested directory structure. the first argument
// it takes should be either a file or directory.

exports.compile_project = function(cb){

  process.stdout.write('compiling... '.grey)
  global.options.debug.log('')

  var compiler = new Compiler();
  _.bindAll(compiler);

  // handle compile errors
  compiler.on('error', function(err){
    console.error("\n\n------------ ERROR ------------\n\n".red + err + "\n");
    utils.add_error_messages.call(this, err, this.finish);
  });

  // callback for compilation process
  compiler.once('finished', function(){
    process.stdout.write('done!\n'.green)
    cb();
  });

  // main compile process
  // --------------------
  // tried to make the code as clear as possible, email me with questions
  // if you are confused and trying to understand or contribute!

  // analyze project should change to just analyze, and take either the
  // file or directory as input. it should however spit out the same array.
  // this is much like how any other compiler works (generate AST, parse), and
  // I feel silly for not having realized this earlier.

  // i think analyze and process should also be split out to separate functions
  // within roots' api.

  utils.analyze_project().then(create_folders).then(function(project){
    global.options.debug.log('compiling and copying files');

    async.parallel([compile_files, copy_static_files], compiler.finish)

    function compile_files(cb){
      async.map(project.compiled_files, compiler.compile, cb);
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