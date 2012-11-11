var copySync = require('../utils/copy_sync'),
    fs = require('fs'),
    path = require('path'),
    current_directory = path.normalize(process.cwd()),
    run = require('child_process').exec,
    colors = require('colors');

var _plugin = function(command){

  // passing no options should display a short help dialouge

  // create plugins directory if it doesn't exist already
  var plugin_folder_path = path.join(current_directory, 'plugins');
  !fs.existsSync(plugin_folder_path) && fs.mkdirSync(plugin_folder_path);

  // generate a new plugin template
  // TODO: add option for --js flag

  if (command[0] === 'generate') {
    var source = path.join(__dirname, '../../templates/plugin/template.coffee');
    var destination = path.join(current_directory, 'plugins/template.coffee');

    copySync(source, destination);
    console.log('\nplugin template generated at `/plugins/template.coffee`\n'.green);
  }


  // install a roots plugin from git repo
  if (command[0] === 'install') {

    var plugin_dir = path.join(current_directory, 'plugins', command[1].replace(/.*\//, ""));

    run('git clone https://github.com/' + command[1] + " " + plugin_dir, function(err, out){
      if (err) return process.stdout.write(err.toString().red);
      console.log(command[1].green + ' installed!'.green);
    });

  }

}

module.exports = { execute: _plugin }