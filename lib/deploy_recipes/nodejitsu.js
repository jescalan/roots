var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    semver = require('semver'),
    roots = require('../index'),
    run = require('child_process').exec,
    shell = require('shelljs');

var nodejitsu = module.exports = {};

nodejitsu.check_install_status = function(cb){
  if (!shell.which('jitsu')){
    console.log("You need to install nodejitsu first.".red);
    console.log("Make sure node.js is installed then run `npm install jitsu -g`".red);
  } else {
    cb();
  }
};

nodejitsu.check_credentials = function(cb){
  console.log('checking credentials...'.grey);
  run('jitsu list', { timeout: 5000 }, function(err, out){
    if (err) { return console.error("\n  you are not logged in to nodejitsu\n  run `jitsu login` to make this happen : )\n".red); }
    cb();
  });
};

nodejitsu.add_config_files = function(cb){
  // if there's a package.json, config files are probably already there
  if (!fs.existsSync(path.join(roots.project.root_dir, 'package.json'))) {

    var source = path.join(__dirname, '../../templates/deploy/nodejitsu') + "/*";
    shell.cp('-rf', source, roots.project.root_dir);

    // put an app name in the package.json file
    var pkg = require(path.join(roots.project.root_dir, 'package.json'));
    pkg.name = pkg.subdomain = this.name === '' ? path.basename(roots.project.root_dir) : this.name;
    fs.writeFileSync(path.join(roots.project.root_dir, 'package.json'), JSON.stringify(pkg));

    console.log('nodejitsu config files copied'.grey);
    cb();
  } else {
    cb();
  }
};

nodejitsu.push_code = function(cb){
  console.log('deploying to nodejitsu (this may take a few seconds)...'.grey);

  // bump version
  var pkg = require(path.join(roots.project.root_dir, 'package.json'));
  pkg.version = semver.inc(pkg.version, 'build');
  fs.writeFileSync(path.join(roots.project.root_dir, 'package.json'), JSON.stringify(pkg));

  var cmd = shell.exec('jitsu deploy');
  if (cmd.code > 0) { return false }

  // console.log('\nfinish the deploy:'.red);
  // console.log('run '.grey + '`jitsu deploy`'.green + ' and it will be done!\n'.grey);
  cb();
};
