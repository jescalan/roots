var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    run = require('child_process').exec,
    config = require('../global_config'),
    current_directory = path.normalize(process.cwd());

var _new = function(commands){

  if (typeof commands[0] === "undefined") {
    return console.error('make sure to pass a name for your project!'.red);
  }

  // 
  // get the correct template
  // 

  var source = get_template(commands[1]);
  if (source.error) { return console.error(source.error) }

  function get_template(cmd){
    var templates = config.get().templates;
    var name = cmd ? cmd.slice(2) : templates['default'];
    var tmpl = cmd ? templates[name] : name;
    var tmpl_path = path.join(__dirname, '../../templates/new', name);

    // if it's not in the global config, we don't have it
    if (!tmpl) { return { error: 'template not found' } }

    // if it's already been downloaded, we're good
    if (fs.existsSync(tmpl_path)) { return tmpl_path }

    // if we have a git url, try to download it
    if (tmpl.match(/^(https:|git@)/)) {

      // if git is not installed, no good
      if (!shell.which('git')) { return { error: 'please install git - check out http://git-scm.com' } }

      var clone_command = shell.exec('git clone ' + tmpl + ' ' + tmpl_path);

      if (clone_command.code === 0) {
        return tmpl_path
      } else {
        return { error: clone_command }
      }

    }

    return { error: 'misconfigured template path' }

  }

  // copy the template into the current directory
  var destination = path.join(current_directory, commands[0]);
  shell.cp('-r', source + '/*', destination);

  // add current roots version to app.coffee
  var app_config_path = path.join(destination, 'app.coffee')
  if (fs.existsSync(app_config_path)){
    var app_config = fs.readFileSync(app_config_path, 'utf8');
    var current_version = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'), 'utf8')).version;
    fs.writeFileSync(app_config_path, "# roots v" + current_version + '\n' + app_config);
  }

  // done!
  console.log('\nnew project created at /'.green + commands[0].green + '\n');

  run("git init " + destination, function(err){
    if (err) {
      console.log("You should install git ASAP.".red);
      console.log('Check out http://git-scm.com/ for a quick and easy download\n'.yellow);
    }
  });
};

module.exports = { execute: _new };
