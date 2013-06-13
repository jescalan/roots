var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    run = require('child_process').exec,
    colors = require('colors'),
    fresher = require('fresher'),
    config = require('../global_config'),
    current_directory = path.normalize(process.cwd());

var _new = function(commands){

  if (typeof commands[0] === "undefined") {
    return console.error('make sure to pass a name for your project!'.red);
  }

  // 
  // check for a new version
  // 

  // if the request takes more than 2.5 seconds to come back, forget it
  var update_checked = false;
  var guard = setTimeout(function(){ !update_checked && process.exit(); }, 2500)

  // check against npm
  var update = fresher('roots', path.join(__dirname, '../../package.json'), function(err, update){
    clearTimeout(guard)
    if (update){
      update_checked = true;
      console.log('a new version of roots is out'.yellow);
      console.log('update with ' + 'npm install roots -g'.bold);
      console.log('');
    }
  });

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
    var exists = fs.existsSync(tmpl_path);

    // if it's not in the global config, we don't have it
    if (!tmpl) { return { error: 'template not found' } }

    // if we have a git url, download/update it
    if (tmpl.match(/^(https:|git@)/)) {

      // if git is not installed, no good
      if (!shell.which('git')) {
        return { error: 'please install git - check out http://git-scm.com' }
      }

      // if it has already been downloaded, update the repo
      if (exists) {
        var pull_command = shell.exec('cd ' + tmpl_path + '; git pull', { silent: true });

        if (pull_command.code === 0) {
          return tmpl_path
        } else {
          return { error: pull_command }
        }
      }

      // if not, clone it down
      var clone_command = shell.exec('git clone ' + tmpl + ' ' + tmpl_path, { silent: true });

      if (clone_command.code === 0) {
        return tmpl_path
      } else {
        return { error: clone_command }
      }

    }

    // if it's already been downloaded, we're good
    if (exists) { return tmpl_path }

    // if all else fails...
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
