require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    util = require('util'),
    shell = require('shelljs'),
    EventEmitter = require('events').EventEmitter,
    adapters = require('./adapters'),
    compress = require('./utils/compressor'),
    Helper = require('./utils/compile-helper');

var Compiler = function(){ EventEmitter.call(this); }
util.inherits(Compiler, EventEmitter)
module.exports = Compiler

Compiler.prototype.finish = function(){
  this.emit('finished');
}

Compiler.prototype.compile = function(file, cb){
  var adapter = get_adapter_by_extension(path.extname(file).slice(1));
  adapter.compile(file, Helper, function(){
    if (err) { return this.emit('error', err) }
    cb();
  });
}

Compiler.prototype.copy = function(file){
  // TODO: Run the file copy operations as async (ncp)
  // TODO: Make sure these file paths are correct
  var source = path.join(process.cwd(), file);
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
    plugins = fs.existsSync(plugin_path) && shell.ls(plugin_path);

function get_adapter_by_extension(file_type){

  // look in core first
  for (var i = 0; i < adapters.length; i++) {
    if (compiler.settings.file_type == file_type) { return compiler; }
  }

  // then look in plugins
  for (var i = 0; i < plugins.length; i++) {
    if (plugins[i].match(/.*\.[js|coffee]+$/)) {
      var compiler = require(path.join(plugin_path, plugins[i]));
      if (compiler.settings && compiler.settings.file_type == file_type) { return compiler; }
    }
  }

  // if all else fails...
  return false
}