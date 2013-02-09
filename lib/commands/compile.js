var compiler = require('../roots'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(no_compress){
  if (no_compress[0] !== '--no-compress') {
    global.options.compress = true;
  }
  
  shell.rm('-rf', path.join(process.cwd(), 'public'));
  compiler.compile_project(process.cwd(), function(){});

  if (no_compress[0] !== '--no-compress') {
    process.stdout.write('\nminifying & compressing...\n'.grey);
  }
};

module.exports = { execute: _compile, needs_config: true };
