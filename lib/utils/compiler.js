require('coffee-script');

var path = require('path'),
    get_compiler = require('./get_compiler'),
    util = require('util'),
    EventEmitter = require('events').EventEmitter,
    fs = require('fs');

function Compiler(){ EventEmitter.call(this); }
util.inherits(Compiler, EventEmitter)

Compiler.finish = function(){
  this.emit('finished');
}

Compiler.compile = function(files, callback){
  var Helper = require('../compilers/compile-helper');

  async.forEach(files, function(file, cb){
    var compiler = get_compiler(path.extname(file).replace(/^\./,''));
    compiler.compile(file, Helper, cb);
  }, complete);

  function complete(err){
    if (err) { return this.emit('error', err) }
    callback();
  }

}

module.exports = Compiler