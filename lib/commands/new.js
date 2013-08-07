var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    run = require('child_process').exec,
    roots = require('../index'),
    config = require('../global_config'),
    colors = require('colors');

var _new = function(args){
  if (args._.length < 2) {
    return roots.print.log('make sure to pass a name for your project!', 'red');
  }
  var name = args._[1];

  // get the correct template
  var template_name;
  for (var k in args){ if (k !== '_' && k !== '$0') { template_name = k; } }

  var source = get_template(template_name);
  if (source.error) return console.error('\n' + source.error.red + '\n');

  // copy the template into the current directory
  var destination = path.join(roots.project.rootDir, name);
  shell.cp('-r', source + '/*', destination);

  // add current roots version to app.coffee
  var app_config_path = path.join(destination, 'app.coffee');
  fs.existsSync(app_config_path) && add_roots_version(app_config_path);

  // initialize git
  run("git init " + destination, function(err){
    if (err) {
      roots.print.log("You should install git ASAP.", 'red');
      roots.print.log('Check out http://git-scm.com/ for a quick and easy download\n', 'yellow');
    }
  });

  // done!
  roots.print.log('\nnew project created at /' + name + '\n', 'green');
};

module.exports = { execute: _new };

//
// @api private
//

function get_template(template_name){
  var templates = config.get().templates;
  var name = template_name ? template_name : templates['default'];
  var tmpl = template_name ? templates[name] : name;
  var tmpl_path = path.join(__dirname, '../../templates/new', name);
  var exists = fs.existsSync(tmpl_path);

  // if it's not in the global config, we don't have it
  if (!tmpl) return { error: 'template not found' };

  // if we have a git url, download/update it
  if (tmpl.match(/^(https:|git@)/)) {

    // if git is not installed, no good
    git_installed = check_git_install();
    if (!git_installed.status) return git_installed.error;

    // if it has already been downloaded, update the repo
    if (exists) return update_git_repo(tmpl_path);

    // if not, clone it down
    return clone_git_repo(tmpl, tmpl_path);

  }

  // if it's already been downloaded, we're good
  if (exists) return tmpl_path;

  // if all else fails...
  return { error: 'misconfigured template path' };
}

function add_roots_version(app_config_path){
  var app_config = fs.readFileSync(app_config_path, 'utf8');
  var current_version = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'), 'utf8')).version;
  fs.writeFileSync(app_config_path, "# roots v" + current_version + '\n' + app_config);
}

function check_git_install(){
  if (shell.which('git')) {
    return { status: true };
  } else {
    return { status: false, error: 'please install git - check out http://git-scm.com' };
  }
}

function update_git_repo(tmpl_path){
  var pull_command = shell.exec('cd ' + tmpl_path + '; git pull', { silent: true });

  if (pull_command.code === 0) {
    return tmpl_path;
  } else {
    return { error: pull_command.output }
  }
}

function clone_git_repo(tmpl, tmpl_path){
  // need to chown new in order to copy out correctly
  var chown_command = shell.exec('sudo chown `whoami` ' + path.join(__dirname, '../../templates/new'));
  var clone_command = shell.exec('git clone ' + tmpl + ' ' + tmpl_path, { silent: true });

  if (clone_command.code === 0) {
    return tmpl_path;
  } else {
    return { error: clone_command.output }
  }
}
