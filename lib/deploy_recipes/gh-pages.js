var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs');

var ghpages = module.exports = {};

ghpages.create_project = function(cb){
  // If gh-pages branch doesn't exist, create it
  if (shell.exec('git branch -r | grep gh-pages').output === ''){
    console.log('creating gh-pages branch from master...'.grey);
    var cmd = shell.exec('git checkout master');
    cmd = shell.exec('git checkout -b gh-pages');
    if (cmd.code > 0) { return false; }

    // Remove everything but public/* and move it to the root of gh-pages branch
    cmd = shell.exec('git ls-files | grep -v public | xargs git rm -r');
    cmd = shell.exec('git mv public/* .');
    cmd = shell.exec('git add .');
    cmd = shell.exec('git commit -am "Initial commit to gh-pages branch"');

    // Create GH repo
    // TODO: Switch to request library instead of curl, verify return value
    console.log('creating GitHub repo...'.grey);
    cmd = shell.exec('curl -s -u "' + this.username + '" https://api.github.com/user/repos -d \'{"name":"' + this.name + '"}\' 2>/dev/null');

    // Add origin remote 
    // TODO: Support https remotes via cli switch?
    cmd = shell.exec('git remote add origin git@github.com:' + this.username + '/' + this.name + '.git');
  }
  cb();
};

ghpages.push_code = function(cb){
  // Update gh-pages branch
  console.log('updating gh-pages branch...'.grey);
  var cmd = shell.exec('git checkout gh-pages');
  cmd = shell.exec('git merge -s subtree master');

  // Push to GitHub
  console.log('pushing gh-pages to GitHub...'.grey);
  cmd = shell.exec('git push origin gh-pages');
  if (cmd.code > 0) { return false; }
  console.log('Pushed to GitHub...'.grey);

  // Switch back to master
  cmd = shell.exec('git checkout master');

  cb();
};
