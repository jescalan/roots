var bower = require('bower'),
    shell = require('shelljs'),
    prettyjson = require('prettyjson'),
    path = require('path'),
    roots = require('../index'),
    prettyjson = require('prettyjson');

// this should be configurable
bower.config.directory = roots.project.path('components');

module.exports = function(command){
  // if installing, make the components directory first
  if (command.toString().match('install')) {
    shell.mkdir('-p', roots.project.path('components'));
  }

  bower.commands[command[0] || 'help'].line(['node', __dirname].concat(command))
    .on('end',   function (data) { roots.print.log(prettyjson.render(data)); })
    .on('error', function (err) { throw err; });
};
