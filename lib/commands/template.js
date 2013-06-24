var config = require('../global_config'),
    path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    colors = require('colors');

var _template = function(args){
  var cmd = args._[1];
  switch (cmd){
    case 'add':
      if (args._.length < 4) { usage(); break; }
      var pair = {},
          name = args._[2],
          url = args._[3];
      pair[name] = url;
      config.modify('templates', pair);
      break;
    case 'default':
      if (args._.length < 3) { usage(); break; }
      config.modify('templates', { 'default': args._[2] });
      break;
    case 'remove':
      config.remove('templates', args._[2]);
      break;
    default:
      usage();
  }

}

module.exports = { execute: _template }

function usage(){
  console.log('');
  console.log('usage:'.blue)
  console.log('- add [name] [github_url]:'.bold + ' add a new roots template');
  console.log('- default [name]:'.bold + ' make this template the default');
  console.log('');
}
