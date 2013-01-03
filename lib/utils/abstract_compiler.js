require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    util = require('util'),
    shell = require('shelljs'),
    compilers = require('../compilers').all(),
    compress = require('./compressor'),
    EventEmitter = require('events').EventEmitter,
    Helper = require('../compilers/compile-helper');

function AbstractCompiler(){ EventEmitter.call(this); }
util.inherits(AbstractCompiler, EventEmitter)
module.exports = AbstractCompiler

AbstractCompiler.prototype.finish = function(){
  this.emit('finished');
}

AbstractCompiler.prototype.compile = function(file, cb){
  var compiler = get_compiler_by_extension(path.extname(file).slice(1));
  compiler.compile(file, Helper, function(){
    if (err) { return this.emit('error', err) }
    cb();
  });
}

AbstractCompiler.prototype.copy = function(file){
  // TODO: Run the file copy operations as async using fs.copy
  // TODO: Correct the target_folder variable
  var source = path.join(process.cwd(), target_folder, file);
  var destination = path.join(process.cwd(), 'public', file);
  var extname = path.extname(file).slice(1);
  var types = ['html', 'css', 'js'];

  if (types.indexOf(extname) > 0) {
    var write_content = fs.readFileSync(source, 'utf8');
    if (global.options.compress) { write_content = compress(write_content, extname); }
    fs.writeFileSync(destination, write_content);
  } else {
    shell.cp(source, destination);
  }
}

// 
// @api private
// 

var plugin_path = path.join(process.cwd() + '/plugins'),
    plugins = shell.ls(plugin_path);

function get_compiler_by_extension(file_type){

  // look in core first
  for (var i = 0; i < compilers.length; i++) {
    if (compiler.settings.file_type == file_type) { return compiler; }
  }

  // then look in plugins
  for (var i = 0; i < plugins.length; i++) {
    if (file.match(/.*\.[js|coffee]+$/)) {
      var compiler = require(path.join(plugin_path, file));
      if (compiler.settings && compiler.settings.file_type == file_type) { return compiler; }
    }
  }

  // if all else fails...
  return false
}