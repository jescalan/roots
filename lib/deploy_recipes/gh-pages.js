var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs');

var ghpages = module.exports = {};

var gh_helper = {}

gh_helper.find_repo = function(repo_name) {

}

ghpages.create_project = function(cb){
  // if there's a gh-pages branch, we're ready to rawk
  if (shell.exec('git branch -r | grep gh-pages').output === ''){
    console.log('creating gh-pages banch...'.grey);
    var cmd = shell.exec('git checkout --orphan gh-pages');
    if (cmd.code > 0) { return false; }
    cmd = shell.exec('/bin/ls | grep -v public | xargs git rm -rf');
    cmd = shell.exec('git mv public/* .');
    cmd = shell.exec('rmdir public');
    cmd = shell.exec('git add .; git commit -am "compress and deploy"');
    // Create GH repo
    console.log('creating GitHub repo...'.grey);
    cmd = shell.exec('curl -s -u "' + this.username + '" https://api.github.com/user/repos -d \'{"name":"' + this.name + '"}\' 2>/dev/null');
    cmd = shell.exec('git remote add origin git@github.com:' + this.username + '/' + this.name + '.git');
  }
  cb();
};

ghpages.push_code = function(cb){
  console.log('pushing gh-pages to GitHub...'.grey);
  var cmd = shell.exec('git push origin gh-pages');
  if (cmd.code > 0) { return false; }
  console.log('Pushed to GitHub...'.grey);
  cmd = shell.exec('git checkout master')
  cb();
};
