require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    util = require('util'),
    shell = require('shelljs'),
    EventEmitter = require('events').EventEmitter,
    get_compiler = require('./get_compiler'),
    compress = require('./compressor'),
    Helper = require('../compilers/compile-helper'),
    current_directory = path.normalize(process.cwd());

function Compiler(){ EventEmitter.call(this); }
util.inherits(Compiler, EventEmitter)

Compiler.prototype.finish = function(){
  this.emit('finished');
}

Compiler.prototype.compile = function(file, cb){
  var compiler = get_compiler(path.extname(file).slice(1));
  compiler.compile(file, Helper, function(){
    if (err) { return this.emit('error', err) }
    cb();
  });
}

Compiler.prototype.copy = function(file){
  // TODO: Correct the target_folder variable
  var source = path.join(current_directory, target_folder, file);
  var destination = path.join(current_directory, 'public', file);
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

module.exports = Compiler