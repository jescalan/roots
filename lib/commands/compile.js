var compiler = require('../roots');

var _compile = function(){
  compiler.compile_project();
}

module.exports = { execute: _compile, needs_config: true }