var fs = require('fs.extra')
    path = require('path'),
    current_directory = path.normalize(process.cwd()),
    colors = require('colors');

var _plugin = function(command){

  // passing no options should display a short help dialouge

  // create plugins directory if it doesn't exist already
  fs.mkdirpSync(path.join(current_directory, 'plugins'));

  // generate a new plugin template
  // TODO: add option for --js flag
  if (command == 'generate') {
    var source = path.join(__dirname, '../../templates/plugin/template.coffee');
    var destination = path.join(current_directory, 'plugins/template.coffee');

    fs.copy(source, destination, function (err) {
     if (err) { return console.log(err); }
     console.log('\nplugin template generated at `/plugins/template.coffee`\n'.green);
    });
  }

}

module.exports = { execute: _plugin }