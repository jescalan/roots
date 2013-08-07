var path = require('path'),
    fs = require('fs'),
    colors = require('colors'),
    readdirp = require('readdirp'),
    shell = require('shelljs'),
    roots = require('../index');

var gh_pages = module.exports = {};
var original_branch;

gh_pages.check_install_status = function(cb){
  // ensure that user has git installed
  if (!shell.which('git')){
    roots.print.log("You must install git. We recommend using homebrew", 'red');
    return false;
  }

  // Make sure there is a remote origin
  if (shell.exec('git remote | grep origin', {silent: true}).output === ''){
    roots.print.log("Make sure you have a remote origin branch for github", 'red');
    return false;
  }

  // save the original branch
  original_branch = execute('git rev-parse --abbrev-ref HEAD', 'you need to make a commit before deploying');
  original_branch = original_branch.output.trim();
  roots.print.debug('starting on branch ' + original_branch);
  cb();
};

gh_pages.add_config_files = function(cb){
  shell.exec('git branch | grep gh-pages', { silent: true }).output !== '' && delete_gh_pages_branch();
  console.log('switching to gh-pages branch'.grey);
  create_gh_pages_branch();
  checkout_gh_pages_branch();
  console.log('removing source files'.grey);
  remove_everything_except_public(function(){
    console.log('moving public to root'.grey);
    dump_public_to_root();
    cb();
  });
};

gh_pages.push_code = function(cb){

  // push to origin/gh-pages
  roots.print.log('pushing to origin/gh-pages branch'.grey);
  execute("git push origin gh-pages --force");

  // switch back to the original branch
  roots.print.debug('switching back to the ' + original_branch + ' branch');
  execute('git checkout ' + original_branch);

  // Profit
  roots.print.log('github pages site deployed', 'grey');
  cb();
};

//
// @api private
//

// executes a command, throws if there's an error
function execute(input, error){
  var cmd = shell.exec(input, { silent: true });
  if (cmd.code > 0) {
    if (error) { throw error.red } else { throw JSON.stringify(cmd.output).red }
  } 
  return cmd
}

function delete_gh_pages_branch(){ execute('git branch -D gh-pages') }
function create_gh_pages_branch(){ execute('git branch gh-pages') }
function checkout_gh_pages_branch(){ execute('git checkout gh-pages') }

function remove_everything_except_public(cb){
  var opts = { root: '', directoryFilter: ['!' + roots.project.dirs['public'], '!.git'] };

  readdirp(opts, function(err, res){
    if (err) return roots.print.error(err);
    res.files.forEach(function(f){ shell.rm(f.path); });
    res.directories.forEach(function(f){ shell.rm('-rf', f.path); });
    cb();
  });
}

function dump_public_to_root(){
  var target = path.join(roots.project.dirs['public'], '*');
  execute('mv -f ' + path.resolve(target) + ' ' + process.cwd());
  shell.rm('-rf', path.resolve('public'));
}
