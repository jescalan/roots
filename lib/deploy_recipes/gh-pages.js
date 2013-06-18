var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    readdirp = require('readdirp'),
    shell = require('shelljs');

var gh_pages = module.exports = {};

gh_pages.check_install_status = function(cb){
  // Verifying the user has Git installed
  if (!shell.which('git')){
    console.error("You must install git. We recommend using homebrew".red);
    return false
  }

  // Make sure there is a remote origin
  if (shell.exec('git remote | grep origin').output === ''){
    console.error("Make sure you have a remote origin branch for github".red);
    return false
  }

  cb();

};

gh_pages.create_project = function(cb){
  if (shell.exec('git branch | grep gh-pages').output === ''){
    create_gh_pages_branch(cb);
  } else {
    shell.exec('git checkout gh-pages'); cb();
  }
};

gh_pages.push_code = function(cb){
  // Move contents of public folder to the project root
  var public_folder = options.output_folder;
  var target = path.join(public_folder, '*');

  console.log('moving the compiled roots project to the project root'.grey);
  var cmd = shell.mv('-f', path.resolve(target), process.cwd());
  shell.rm('-rf', 'public');

  // Commit and push 
  console.log('commiting and pushing new files to origin/gh-pages branch');
  var commit_msg = "compress and deploy";
  var commit = shell.exec("git add *; git commit -am '" + commit_msg + "'; git push origin gh-pages --force");
  if (commit.code > 0) { return false; }
  
  // Profit
  console.log('github pages site deployed'.grey);
  cb();
};

// 
// @api private
// 

function create_gh_pages_branch(cb){
  console.log('creating bare gh-pages branch in project...'.grey);

  // create the gh-pages branch
  var branch = shell.exec('git checkout -b gh-pages');
  if (branch.code > 0) { return false; }

  // remove everything except for the public folder
  var opts = { root: '', directoryFilter: ['!' + options.output_folder, '!.git'] };

  readdirp(opts, function(err, res){
    if (err) { return console.error(err) }
    res.files.forEach(function(f){ shell.rm(f.path); });
    res.directories.forEach(function(f){ shell.rm('-rf', f.path); });
    cb();
  });
}
