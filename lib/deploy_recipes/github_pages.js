var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    run = require('child_process').exec,
    shell = require('shelljs');

var github_pages = module.exports = {};

github_pages.check_install_status = function(cb){
  // Verifying the user has Git installed
  if (!shell.which('git')){
    console.log("You must install git. We recommend using homebrew".red);
  } else {
    cb();
  }
};

github_pages.create_project = function(cb){
  // Assure gh-pages branch doesn't exist
  if(shell.exec('git branch -r | grep gh-pages').output === ''){
    console.log('creating bare gh-pages branch in project...'.grey);

    // Create gh-pages branch
    var branch = shell.exec('git checkout --orphan gh-pages');
    if (branch.code > 0) { return false; }

    // TODO: Remove everything in the old working tree, but the compiled Roots project in the /public folder
    // var public_folder = options.output_folder;
    // readdirp({ root: '.', directoryFilter: [ "!*" + public_folder ] })
    //   .on('data', function (entry) {
    //     // shell.exec("git rm -rf " + entry )
    //     // handle async
    //   });
  }else {
    shell.exec('git checkout gh-pages');
  }
  cb();
};

github_pages.push_code = function(cb){
  // Move contents of public folder to the project root
  var public_folder = options.output_folder;
  var target = path.join(public_folder, '*');

  console.log('moving the compiled Roots project to the project root'.grey);
  var cmd = mv(target, process.cwd() );
  if (cmd.code > 0) { return false; }

  // Commit and push 
  console.log('commiting and pushing new files to origin/gh-pages branch');
  var commit_msg = "compress and deploy";
  var commit = shell.exec("git add *; git commit -am '" + commit_msg + "'; git push origin gh-pages");
  if (cmd.code > 0) { return false; }
  
  // Profit
  console.log('github pages site deployed'.grey);
  cb();
};
