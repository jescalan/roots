var compiler = require('../roots'),
    path = require('path'),
    current_directory = path.normalize(process.cwd());
    rimraf = require('rimraf');

var _compile = function(){
  rimraf.sync(path.join(current_directory, 'public'));
  compiler.compile_project();
  process.stdout.write('done!\n'.green);
}

module.exports = { execute: _compile, needs_config: true }