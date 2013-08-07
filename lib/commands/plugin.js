var fs = require('fs'),
    shell = require('shelljs'),
    path = require('path'),
    run = require('child_process').exec,
    colors = require('colors'),
    roots = require('../index');

var _plugin = function(args){

  var cmd = args._[1];

  // create plugins directory if it doesn't exist already
  var plugin_folder_path = path.join(process.cwd(), 'plugins');
  !fs.existsSync(plugin_folder_path) && fs.mkdirSync(plugin_folder_path);

  // generate a new plugin template
  if (cmd === 'generate') {
    var source = path.join(__dirname, '../../templates/plugin/template.coffee');
    var destination = path.join(process.cwd(), 'plugins/');
    if (args.js) source = path.join(__dirname, '../../templates/plugin/template.js');

    shell.cp('-r', source, destination);
    roots.print.log('\nplugin template generated at `/plugins`\n', 'green');

  // install a roots plugin from git repo
  } else if (cmd === 'install') {

    if (args._.length < 3) {
      return console.error('please provide a github username/repo');
    } else {
      var repo_string = args._[2];
    }

    var plugin_dir = path.join(process.cwd(), 'plugins', repo_string.replace(/.*\//, ""));

    run('git clone https://github.com/' + repo_string + " " + plugin_dir, function(err){
      if (err) return roots.print.error(err);
      roots.print.log(repo_string + ' installed!', 'green');
    });

  // help
  } else {
    roots.print.log('\nusage:\n', 'blue');
    roots.print.log("- " + "generate: ".bold + "generate a coffeescript plugin template. `--js` for javascript\n");
    roots.print.log("- " + "install <username/repo>: ".bold + "install a plugin from a github repo\n\n");
  }

};

module.exports = { execute: _plugin };
