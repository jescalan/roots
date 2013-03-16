var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs');

var ghpages = module.exports = {};

ghpages.create_project = function(cb){
  // if there's a gh-pages branch, we're ready to rawk
  if (shell.exec('git branch -r | grep gh-pages').output === ''){
    console.log('creating gh-pages banch...'.grey);
    var cmd = shell.exec('git checkout --orphan gh-pages');
    if (cmd.code > 0) { return false; }
    cmd = shell.exec('curl -u "' + this.username + '" https://api.github.com/user/repos -d \'{"name":"' + this.name + '"}\'');
  }
  cb();
};

ghpages.push_code = function(cb){
  console.log('pushing gh-pages to GitHub...'.grey);
  /*var cmd = shell.exec('git push -u origin master');
  if (cmd.code > 0) { return false; }
  console.log('Pushed to GitHub'.grey);
  cb();*/
};
