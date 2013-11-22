var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs'),
    roots = require('../index');

var heroku = module.exports = {};

heroku.check_install_status = function(cb){
  if (!shell.which('heroku')){
    roots.print.log("You need to install heroku first. Here's the download page", 'red');
    setTimeout(function(){ require('open')('https://toolbelt.heroku.com/'); }, 700);
  } else {
    cb();
  }
};

heroku.check_credentials = function(cb){
  roots.print.log('checking credentials...', 'grey');
  run('heroku auth:whoami', { timeout: 5000 }, function(err, out){
    if (err) return roots.print.log("\n  you are not logged in to heroku\n  run `heroku auth:login` to make this happen : )\n", 'red');
    cb();
  });
};

heroku.add_config_files = function(cb){
  // if there's a procfile, heroku config files are probably there
  if (!fs.existsSync(path.join(roots.project.rootDir, 'Procfile'))) {
    var source = path.join(__dirname, '../../templates/deploy/heroku') + "/*";
    shell.cp('-rf', source, roots.project.rootDir);
    roots.print.log('heroku config files copied', 'grey');
  }
  cb();
};

heroku.create_project = function(cb){
  // if there's a heroku branch, there's probably already a heroku app
  if (shell.exec('git branch -r | grep heroku').output === ''){
    roots.print.log('creating app on heroku...', 'grey');
    var cmd = shell.exec('heroku create ' + this.name);
    if (cmd.code > 0) return false;
  }
  cb();
};

heroku.push_code = function(cb){
  roots.print.log('pushing master branch to heroku (this may take a few seconds)...', 'grey');
  var cmd = shell.exec('git push heroku master');
  if (cmd.code > 0) return false;
  roots.print.log('heroku app launched', 'grey');
  cb();
};
