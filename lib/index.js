var colors = require('colors'),
    async = require('async'),
    shell = require('shelljs'),
    path = require('path'),
    fs = require('fs'),
    _ = require('underscore'),
    readdirp = require('readdirp'),
    minimatch = require('minimatch'),
    Q = require('q'),
    deferred = Q.defer(),
    add_error_messages = require('./utils/add_error_messages'),
    output_path = require('./utils/output_path'),
    yaml_parser = require('./utils/yaml_parser'),
    precompile_templates = require('./precompiler'),
    Compiler = require('./compiler'),
    Print = require('./print');

// this is just temporary until we actually move in the real Project class
exports.project = {
  debug: true // gets set in config_parser
};

// initialization and error handling
var print = exports.print = new Print();
var compiler = exports.compiler = new Compiler();

_.bindAll(compiler, 'compile', 'copy', 'finish');

compiler.on('error', function(err){
  print.error(err);
  add_error_messages.call(this, err, this.finish);
});

// @api public
// Given a root (folder or file), compile with roots and output to /public

exports.compile_project = function(root, done){

  compiler.once('finished', function(){
    print.log('done!\n', 'green');
    done();
  });

  print.log('compiling... ', 'grey');
  print.debug('');

  analyze(root)
  .then(create_folders)
  .then(compile)
  .then(precompile_templates)
  .then(compiler.finish, function(err){ compiler.emit('error', err); });

};

// @api private
// parse file/directory input and generate mini roots-style AST.

function analyze(root){
  print.debug('analyzing project', 'yellow');

  var ast = {
    folders: {},
    compiled_files: [],
    static_files: [],
    dynamic_files: []
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

    // clear the dynamic locals first
    global.options.locals.site = null;

    // read through the current project and organize the files
    var options = {
      root: root,
      directoryFilter: global.options.ignore_folders,
      fileFilter: global.options.ignore_files
    };

    readdirp(options, function(err, res){
      if (err) print.error(err);

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
    if (yaml_parser.detect(file)) {
      ast.dynamic_files.push(file);
    } else if (is_template(file)) {
      return false;
    } else if (is_compiled(file)) {
      ast.compiled_files.push(file);
    } else {
      ast.static_files.push(file);
    }
  }

  function is_compiled(file){
    return global.options.compiled_extensions.indexOf(path.extname(file).slice(1)) >= 0;
  }

  function is_template(file){
    return minimatch(file, '**/' + global.options.templates + '/*');
  }

}

// @api private
// compile and write the files given a roots AST.

function compile(ast){

  print.debug('compiling and copying files', 'yellow');

  // compile dynamic content first, if present
  async.map(ast.dynamic_files, compiler.compile, function(err1){
    async.parallel([compile_files, copy_static_files], function(err2){
      if (err1 || err2) deferred.reject(err);
      deferred.resolve(ast);
    });
  });

  function compile_files(cb){ async.map(ast.compiled_files, compiler.compile, cb); }
  function copy_static_files(cb){ async.map(ast.static_files, compiler.copy, cb); }

  return deferred.promise;
}

// @api private
// create the folder structure for the project

function create_folders(ast){
  print.debug('creating folders', 'yellow');
  shell.mkdir('-p', path.join(process.cwd(), options.output_folder));

  for (var key in ast.folders) {
    shell.mkdir('-p', output_path(ast.folders[key]));
    print.debug('created ' + ast.folders[key].replace(process.cwd(),''));
  }

  return Q.fcall(function(){
    return ast;
  });
}
