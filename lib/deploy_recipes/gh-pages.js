var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs'),
    prompt = require('prompt'),
    request = require('request');

var ghpages = module.exports = {};

ghpages.create_project = function(cb){
  var name = this.name;
  var username = this.username;

  // TODO: Refactor into some reusable helper methods?

  // If gh-pages branch doesn't exist, create it
  if (shell.exec('git branch -r | grep gh-pages').output === ''){
    // Ensure the GH repo exists
    console.log('creating GitHub repo...'.grey);
    prompt.start();
    prompt.message = prompt.delimiter = "";
    console.log("Please Enter Your GitHub Credentails".yellow.inverse);
    prompt.get([{ name: 'password', hidden: true, required: true }], function(err, result) {
      var password = result.password;
      request.post("https://api.github.com/user/repos", {
        'auth': {
          'username': username,
          'password': password
        },
        'body': JSON.stringify({ 'name': name })
      }, function(err, res, d) {
        d = JSON.parse(d);
        if (err) {
          console.log("Error".inverse.red);
          console.log(err);
        }
        if (d.errors && d.errors.length) {
          console.log("Error".inverse.red);
          console.log(d.errors);
          return false;
        } else {
          console.log("GitHub repo '" + name + "' created...".grey);

          // Add origin remote 
          // TODO: Support https remotes via cli switch?
          cmd = shell.exec('git remote add origin git@github.com:' + username + '/' + name + '.git');

          // Create the gh-pages branch
          console.log('creating gh-pages branch from master...'.grey);
          var cmd = shell.exec('git checkout master');
          cmd = shell.exec('git checkout -b gh-pages');
          // Remove everything but public/* and move it to the root of gh-pages branch
          cmd = shell.exec('git ls-files | grep -v public | xargs git rm -r');
          cmd = shell.exec('git mv public/* .');
          cmd = shell.exec('git add .');
          cmd = shell.exec('git commit -am "Initial commit to gh-pages branch"');
          cb();
        }
      });
    });
  } else {
    cb();
  }
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

  // Switch back to master
  cmd = shell.exec('git checkout master');

  cb();
};
