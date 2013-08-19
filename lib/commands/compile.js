var roots = require('../index'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(args){
  shell.rm('-rf', roots.project.path('public'));
  roots.compile_project(roots.project.rootDir, function(){});

  if(roots.project.conf('compress')){
    roots.print.log('\nminifying & compressing...\n', 'grey');
  }
};

module.exports = { execute: _compile, needs_config: true };
