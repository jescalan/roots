var bower = require('bower'),
    shell = require('shelljs'),
    path = require('path'),
    roots = require('../index');

// this should be configurable
bower.config.directory = roots.project.path('components');

module.exports = function(command){
  // if installing, make the components directory first
  if (command.toString().match('install')) {
    shell.mkdir('-p', roots.project.path('components'));
  }

  bower.commands[command[0] || 'help'].line(['node', __dirname].concat(command))
    .on('data',  function (data) { data && roots.print.log(data); })
    .on('end',   function (data) { data && roots.print.log(data); })
    .on('error', function (err) { throw err; });
};
