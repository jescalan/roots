var config = require('../global_config'),
    path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    colors = require('colors');

var _template = function(args){
  switch (args[0]){
    case 'add':
      if (args.length < 3) { console.log('pass a name and a github url'); break; }
      var arg = {}; arg[args[1]] = args[2];
      config.modify('templates', arg);
      break;
    case 'default':
      config.modify('templates', { 'default': args[1] });
      break;
    case 'update':
      if (args.length < 2) { console.log('pass a template name'); break; }
      var template_path = path.join(__dirname, '../../templates/new', args[1]);
      console.log(template_path)
      if (!fs.existsSync(template_path)) { return console.error('invalid template') }
      shell.exec('cd ' + template_path + '; git pull');
      break;
    default:
      console.log('');
      console.log('roots template commands:')
      console.log('- add [name] [github_url]:'.bold + ' add a new roots template');
      console.log('- default [github_url]:'.bold + ' make this template the default');
      console.log('');
  }

}

module.exports = { execute: _template }