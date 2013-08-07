var bower = require('bower'),
    shell = require('shelljs'),
    prettyjson = require('prettyjson'),
    path = require('path'),
    roots = require('../index');

// this should be configurable
bower.config.directory = path.normalize("assets/components");

module.exports = function(command){
  // if installing, make the components directory first
  if (command.toString().match('install')) {
    shell.mkdir('-p', path.join(process.cwd(), 'assets/components'));
  }

  bower.commands[command[0] || 'help'].line(['node', __dirname].concat(command))
    .on('end',   function (data) { roots.print.log(prettyjson.render(data)); })
    .on('error', function (err) { throw err; });
};
