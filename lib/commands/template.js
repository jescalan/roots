var config = require('../global_config'),
    colors = require('colors');

var _template = function(args){
  switch (args[0]){
    case 'add':
      if (args.length < 3) { console.log('pass a name and a github url'); break; }
      var arg = {}; arg[args[1]] = args[2];
      config.modify('templates', arg);
      // actually download to templates folder
      break;
    case 'default':
      config.modify('templates', { 'default': args[1] });
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