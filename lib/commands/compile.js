var roots = require('../index'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(args){
  if (args['compress'] == undefined) global.options.compress = true;

  shell.rm('-rf', roots.project.path('public'));
  roots.compile_project(roots.project.rootDir, function(){});

  args['compress'] == undefined && roots.print.log('\nminifying & compressing...\n', 'grey');
};

module.exports = { execute: _compile, needs_config: true };
