var roots = require('../index'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(args){
  if (args['compress'] == undefined) global.options.compress = true;

  shell.rm('-rf', path.join(process.cwd(), options.output_folder));
  roots.compile_project(process.cwd(), function(){});

  args['compress'] == undefined && roots.print.log('\nminifying & compressing...\n', 'grey');
};

module.exports = { execute: _compile, needs_config: true };
