var clijs = require('cli-js'),
    _ = require('underscore'),
    shell = require('shelljs'),
    colors = require('colors'),
    copypaste = require('copy-paste'),
    path = require('path'),
    roots = require('../index');

clijs.config.download_path = path.normalize('assets/components');

module.exports = function(cmd){

  switch (cmd[0]){
    case 'list':
      clijs.commands.list(function(res){
        clijs.print.header('all packages');
        clijs.print.array(_.pluck(res, 'name'));
      });
      break;
    case 'search':
      clijs.commands.search(cmd[1], function(res){
        clijs.print.header('results for ' + cmd[1]);
        clijs.print.array(res);
      });
      break;
    case 'copy':
      clijs.commands.get_url(cmd[1], function(res){
        copypaste.copy(res, function(){});
        roots.print.log('');
        roots.print.log(res, 'green');
        roots.print.log('');
      });
      break;
    case 'info':
      clijs.commands.find(cmd[1], function(res){
        if (res) {
          clijs.print.info(res);
        } else {
          roots.print.log('');
          roots.print.log('no results found', 'red');
          roots.print.log('maybe try a ' + 'search'.bold + '?');
          roots.print.log('');
        }
      });
      break;
    case 'install':
      shell.mkdir('-p', path.join(process.cwd(), 'assets/components'));
      clijs.commands.download(cmd[1], function(err, pkg){
        roots.print.log('');
        roots.print.log('installed ' + pkg.name);
        roots.print.log('');
      });
      break;
    default:
      clijs.commands.help();
  }
};
