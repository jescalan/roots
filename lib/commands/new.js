var path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    run = require('child_process').exec,
    config = require('../global_config'),
    Git = require('../utils/git'),
    current_directory = path.normalize(process.cwd());

var _new = function(commands){
  if (typeof commands[0] === "undefined") {
    return console.error('make sure to pass a name for your project!'.red);
  }

  // get the correct template
  var source = get_template(commands[1], git);
  if (source.error) { return console.error(source.error) }

  // copy the template into the current directory
  var destination = path.join(current_directory, commands[0]);
  shell.cp('-r', source + '/*', destination);

  // add current roots version to app.coffee
  var app_config_path = path.join(destination, 'app.coffee')
  fs.existsSync(app_config_path) && add_roots_version(app_config_path)

  // initialize git in the new project
  var git = new Git(destination);

  if (!git) {
    console.log("You should install git ASAP.".red);
    console.log('Check out http://git-scm.com/ for a quick and easy download\n'.yellow);
  } else {
    git.init_sync();
  }

  // done!
  console.log('\nnew project created at /'.green + commands[0].green + '\n');
};

module.exports = { execute: _new };

//
// @api private
//

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

    var git = new Git(tmpl_path);

    // if git is not installed, no good
    if (!git) { return console.error('make sure git is installed - http://git-scm.com') }

    // if it has already been downloaded, update the repo
    if (exists) { git.pull_sync(); return tmpl_path }

    // if not, clone it down
    git.clone_sync(tmpl);
    return tmpl_path;

  }

  // if it's already been downloaded, we're good
  if (exists) { return tmpl_path }

  // if all else fails...
  return { error: 'misconfigured template path' }
}

function add_roots_version(app_config_path){
  var app_config = fs.readFileSync(app_config_path, 'utf8');
  var current_version = JSON.parse(fs.readFileSync(path.join(__dirname, '../../package.json'), 'utf8')).version;
  fs.writeFileSync(app_config_path, "# roots v" + current_version + '\n' + app_config);
}
