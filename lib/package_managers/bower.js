var bower = require('bower'),
    shell = require('shelljs'),
    roots = require('../index'),
    path = require('path');

// this should be configurable
bower.config.directory = path.normalize("assets/components");

module.exports = function(command){
  // if installing, make the components directory first
  if (command.toString().match('install')) {
    shell.mkdir('-p', path.join(roots.project.rootDir, 'assets/components'));
  }

  bower.commands[command[0] || 'help'].line(['node', __dirname].concat(command))
    .on('data',  function (data) { data && console.log(data); })
    .on('end',   function (data) { data && console.log(data); })
    .on('error', function (err) { throw err; });
}
