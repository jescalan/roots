var colors = require('colors'),
    async = require('async'),
    shell = require('shelljs'),
    path = require('path'),
    fs = require('fs'),
    _ = require('underscore'),
    readdirp = require('readdirp'),
    Q = require('q'),
    deferred = Q.defer(),
    add_error_messages = require('./utils/add_error_messages'),
    output_path = require('./utils/output_path'),
    precompile = require('./precompiler'),
    Compiler = require('./compiler');

// initialization and error handling

var compiler = new Compiler();
_.bindAll(compiler);

compiler.on('error', function(err){
  console.log('\u0007'); // bell sound
  console.error("\n\n------------ ERROR ------------\n\n".red + err + "\n");
  add_error_messages.call(this, err, this.finish);
});

// @api public
// Given a root (folder or file), compile with roots and output to /public

exports.compile_project = function(root, done){

  compiler.once('finished', function(){
    process.stdout.write('done!\n'.green);
    done();
  });

  process.stdout.write('compiling... '.grey);
  global.options.debug.log('');

  analyze(root).then(compile).then(precompile).then(compiler.finish, function(err){
    console.error(err);
  });

};

// @api private
// parse file/directory input and generate mini roots-style AST.

function analyze(root){
  global.options.debug.log('analyzing project');

  var ast = {
    folders: {},
    compiled_files: [],
    static_files: []
  };

  if (fs.statSync(root).isDirectory()) {
    return parse_directory(root);
  } else {
    parse_file(root);
    return Q.fcall(function(){
      return ast;
    });
  }

  function parse_directory(root){

    // format negate pattern
    var ignores = [];
    global.options.ignore_files.forEach(function(pattern){
      ignores.push("!" + pattern.toString().replace(/\//g, ""));
    });

    // read through the current project and organize the files
    var options = {
      root: root,
      directoryFilter: ignores.concat(['!public', '!plugins']),
      fileFilter: ignores
    };

    readdirp(options, function(err, res){
      if (err) {
        console.error(err);
      }

      // populate folders
      ast.folders = _.pluck(res.directories, 'fullPath');

      // populate compiled and copied files
      res.files.forEach(function(file){
        parse_file(file.fullPath);
      });

      deferred.resolve(ast);

    });

    return deferred.promise;
  }

  function parse_file(file){
    if (global.options.compiled_extensions.indexOf(path.extname(file).slice(1)) >= 0) {
      ast.compiled_files.push(file);
    } else {
      ast.static_files.push(file);
    }
  }

}

// @api private
// compile and write the files given a roots AST.

function compile(ast){

  create_folders(ast).then(function(){
    global.options.debug.log('compiling and copying files');

    async.parallel([compile_files, copy_static_files], deferred.resolve);
    
    function compile_files(cb){ async.map(ast.compiled_files, compiler.compile, cb); }
    function copy_static_files(cb){ async.map(ast.static_files, compiler.copy, cb); }
  });

  function create_folders(ast){
    global.options.debug.log('creating folders');
    shell.mkdir('-p', path.join(process.cwd(), 'public'));

    for (var key in ast.folders) {
      shell.mkdir('-p', output_path(ast.folders[key]));
    }

    return Q.fcall(function(){
      return ast;
    });
  }

  return deferred.promise;
}
