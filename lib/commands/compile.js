var roots = require('../index'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(args){
  // this has to turn off compression, but not inject
  // the livereload script. therefore it's not 1:1 with
  // project.mode
  // this is activated when `roots compile --no-compress` is used
  
  // if (args['compress'] == undefined) ...

  shell.rm('-rf', roots.project.path('public'));
  roots.compile_project(roots.project.rootDir, function(){});

  if(roots.project.conf('compress')){
    roots.print.log('\nminifying & compressing...\n', 'grey');
  }
};

module.exports = { execute: _compile, needs_config: true };
