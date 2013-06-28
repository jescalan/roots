var clijs = require('cli-js'),
    _ = require('underscore'),
    shell = require('shelljs'),
    colors = require('colors'),
    copypaste = require('copy-paste'),
    roots = require('../index'),
    path = require('path');

clijs.config.download_path = path.normalize('assets/components');

module.exports = function(cmd){

  switch (cmd[0]){
    case 'list':
      clijs.commands.list(function(res){
        clijs.print.header('all packages')
        clijs.print.array(_.pluck(res, 'name'));
      });
      break;
    case 'search':
      clijs.commands.search(cmd[1], function(res){
        clijs.print.header('results for ' + cmd[1])
        clijs.print.array(res);
      });
      break;
    case 'copy':
      clijs.commands.get_url(cmd[1], function(res){
        copypaste.copy(res, function(){});
        console.log('');
        console.log(res.green);
        console.log('');
      });
      break;
    case 'info':
      clijs.commands.find(cmd[1], function(res){
        if (res) {
          clijs.print.info(res);
        } else {
          console.log('');
          console.log('no results found'.red);
          console.log('maybe try a ' + 'search'.bold + '?')
          console.log('');
        }
      });
      break;
    case 'install':
      shell.mkdir('-p', path.join(roots.project.root_dir, 'assets/components'));
      clijs.commands.download(cmd[1], function(err, pkg){
        console.log('');
        console.log('installed ' + pkg.name);
        console.log('');
      });
      break;
    default:
      clijs.commands.help();
  }

}
