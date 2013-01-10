var path = require('path'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs');

var heroku = module.exports = {};

heroku.name = heroku.cli_name = 'heroku';
heroku.download_url = 'https://toolbelt.heroku.com/';

heroku.check_credentials = function(cb){
  console.log('checking credentials...'.grey);
  run('heroku auth:whoami', { timeout: 500 }, function(err, out){
    if (err) { return console.error("\n  you are not logged in to heroku\n  run `heroku auth:login` to make this happen : )\n".red); }
    cb();
  });
}

heroku.add_config_files = function(cb){
  // if there's a procfile, heroku config files are probably there
  if (!fs.existsSync(path.join(process.cwd(), 'Procfile'))) {
    var source = path.join(__dirname, '../../templates/deploy/heroku') + "/*";
    shell.cp('-rf', source, process.cwd());
    console.log('heroku config files copied'.grey);
  }
  cb();
}

heroku.create_project = function(cb){
  // if there's a heroku branch, there's probably already a heroku app
  if (shell.exec('git branch -r | grep heroku').output !== ''){
    console.log('creating app on heroku...'.grey);
    var cmd = shell.exec('heroku create ' + this.name);
    if (cmd.code > 0) { return false }
  }
  cb();
}

heroku.push_code = function(cb){
  console.log('pushing master branch to heroku (this may take a few seconds)...'.grey);
  var cmd = shell.exec('git push heroku master');
  if (cmd.code > 0) { return false }
  console.log('heroku app launched'.grey);
  cb();
}