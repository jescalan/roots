var roots = require('../index'),
    path = require('path'),
    shell = require('shelljs');

var _compile = function(args){
  if (args['compress'] == undefined) { global.options.compress = true; }

  shell.rm('-rf', path.join(roots.project.root_dir, options.output_folder));
  roots.compile_project(roots.project.root_dir, function(){});

  args['compress'] == undefined && process.stdout.write('\nminifying & compressing...\n'.grey);
};

module.exports = { execute: _compile, needs_config: true };
