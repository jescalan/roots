require('colors')

var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    crypto = require('crypto'),
    os = require('os'),
    osenv = require('osenv'),
    run = require('child_process').exec,
    roots = require('../index'),
    config = require('../global_config');

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
  shell.exec("git init " + destination, { silent: true });

  // done!
  roots.print.log('\nnew project created at /' + name + '\n', 'green');
};

module.exports = { execute: _new };

//
// @api private
//

function get_template(template_name){

  var templates = config.get('templates');
  var name = template_name ? template_name : config.get('default_template');
  var tmpl = templates[name];
  var user = (osenv.user() || generateFakeUser()).replace(/\\/g, '-');
  var tmp_dir = path.join(os.tmpdir ? os.tmpdir() : os.tmpDir(), user);
  var config_dir = process.env.XDG_CONFIG_HOME || path.join(osenv.home() || tmp_dir, '.config');
  var tmpl_path = path.join(config_dir, 'roots/templates', name);
  var exists = fs.existsSync(tmpl_path);

  // if it's not in the global config, we don't have it
  if (!tmpl) return { error: 'template not found' };

  // if git is not installed, no good
  git_installed = check_git_install();
  if (!git_installed.status) return git_installed.error;

  // if it has already been downloaded, update the repo
  if (exists) return update_git_repo(tmpl_path);

  // if not, clone it down
  return clone_git_repo(tmpl, tmpl_path);

  // if it's already been downloaded, we're good
  if (exists) return tmpl_path;

  // if all else fails...
  return { error: 'misconfigured template path' };
}

function generateFakeUser() {
    var uid = [process.pid, Date.now(), Math.floor(Math.random() * 1000000)].join('-');
    return crypto.createHash('md5').update(uid).digest('hex');
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
  var clone_command = shell.exec('git clone ' + tmpl + ' ' + tmpl_path, { silent: true });

  if (clone_command.code === 0) {
    return tmpl_path;
  } else {
    return { error: clone_command.output }
  }
}
