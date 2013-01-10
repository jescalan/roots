var path = require('path'),
    shell = require('shelljs');
    
var heroku = module.exports = {};

heroku.check_credentials = function(cb){
  // check to see if you are logged in
}

heroku.add_config_files = function(cb){
  var source = path.join(__dirname, '../../templates/heroku') + "/*";
  var destination = process.cwd();
  shell.cp('-rf', source, destination);
  console.log('heroku config files copied'.grey);
  cb();
}

// need to deal with the name passing thing
heroku.create_project = function(cb){
  console.log('creating app on heroku...'.grey);
  var name = this.name.length < 1 ? "" : this.name[0];

  var cmd = shell.exec('heroku create ' + name);
  console.log(cmd); // debug

  console.log('new heroku app created at '.green + cmd.output.match(/(http:\/\/.*\/)/)[1].green);
  cb();
}

heroku.push_code = function(cb){
  console.log('pushing master branch to heroku (this may take a few seconds)...'.grey);
  var cmd = shell.exec('git push heroku master');
  console.log(cmd);
  console.log('heroku app launched'.grey);
  cb();
}