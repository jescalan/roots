require('coffee-script');

var path = require('path'),
    fs = require('fs'),
    util = require('util'),
    shell = require('shelljs'),
    EventEmitter = require('events').EventEmitter,
    adapters = require('./adapters'),
    compress = require('./utils/compressor'),
    output_path = require('./utils/output_path'),
    Helper = require('./utils/compile_helper'),
    file_helper = require('./utils/file_helper');

function Compiler(){ EventEmitter.call(this); }
util.inherits(Compiler, EventEmitter);
module.exports = Compiler;

Compiler.prototype.finish = function(){
  this.emit('finished');
};

Compiler.prototype.compile = function(file, cb){
  var adapters = get_adapters_by_extension(file.split('.').slice(1));
  var self = this;
  var fh = file_helper(file);

  adapters.forEach(function(adapter, i){
    console.log('compiling ' + adapter.settings.file_type);

    var intermediate = adapters.length - i - 1 > 0 ? true : false;

    // file should be written here, not in the compiler
    // this way it can also handle layouts

    adapter.compile(fh, function(err, compiled){
      if (err) { return self.emit('error', err); }

      if (intermediate) {
        // pass through to the next compiler
        console.log('passing '.yellow + adapter.settings.file_type.yellow + ' through'.yellow);
        fh.contents = compiled;
      } else {
        // write the file (and layout in the future)
        fh.write(compiled);
      }

      cb();
    });

  });

};

Compiler.prototype.copy = function(file, cb){
  // TODO: Run the file copy operations as async (ncp)
  var destination = output_path(file);
  var extname = path.extname(file).slice(1);
  var types = ['html', 'css', 'js'];

  if (types.indexOf(extname) > 0) {
    var write_content = fs.readFileSync(file, 'utf8');

    if (global.options.compress) {
      write_content = compress(write_content, extname);
    }

    fs.writeFileSync(destination, write_content);
  } else {
    shell.cp('-f', file, destination);
  }

  global.options.debug.log('copied ' + file);
  cb();
};

// @api private

var plugin_path = path.join(process.cwd() + '/plugins'),
    plugins = fs.existsSync(plugin_path) && shell.ls(plugin_path);

function get_adapters_by_extension(extensions){

  var matching_adapters = [];

  extensions.reverse().forEach(function(ext){

    for (var key in adapters) {
      if (adapters[key].settings.file_type == ext) {
        matching_adapters.push(adapters[key]);
      }
    }

  });

  return matching_adapters
}