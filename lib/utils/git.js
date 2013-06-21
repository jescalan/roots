var shell = require('shelljs'),
    exec = require('child_process').exec
    gift = require('gift');

// roots-git
// a very thin layer over [gift](https://github.com/sentientwaffle/gift),
// with a couple of small additions. Initialized with a constructor, optionally
// pass it a directory, defaults to process.cwd().

var git = module.exports = function(dir, silent){
  if (!shell.which('git')) { return false }
  this.dir = dir || process.cwd()
  this.repo = gift(this.dir);
  this.silent = silent || true;
}

// test whether git is installed or not
// @return {boolean}
git.prototype.installed = function(){
  return shell.which('git')
}

// clones down a given repo to the local filesystem
// @param repo {string} path of the repo to clone
// @param target {string} path to clone the repo into
// @param cb {function} callback
git.prototype.clone = function(repo, target, cb){
  var target = target || this.dir;
  exec('git clone ' + repo + ' ' + target, cb);
}

// clones down a given repo to the local filesystem, sync
// @param repo {string} path of the repo to clone
// @param target {string} path to clone the repo into
git.prototype.clone_sync = function(repo, target, cb){
  var target = target || this.dir;
  return shell.exec('git clone ' + repo + ' ' + target, { silent: this.silent });
}

// initializes a new git repository
// @param cb {function} callback
git.prototype.init = function(cb){
  exec('cd ' + this.dir + '; git init', cb);
}

// initializes a new git repository, sync
git.prototype.init_sync = function(){
  return shell.exec('cd ' + this.dir + '; git init', { silent: this.silent });
}

// adds or removes a remote branch
// @param fn {string} either 'add' or 'rm'
// @param name {string} name of the branch to target
// @param cb {function} callback
git.prototype.remote = function(fn, name, cb){
  if (fn == 'add') { this.repo.remote_add(name, cb) }
  if (fn == 'rm') { this.repo.remote_remove(name, cb) }
}

// fetches the given remote branch
// @param name {string} name of the branch to be fetched
// @param cb {function} callback
git.prototype.fetch = function(name, cb){
  this.repo.remote_fetch(name, cb);
}

// returns the status of the repo
// @param cb {function} callback
git.prototype.status = function(cb){
  this.repo.status(cb);
}

// makes a commit to the git repo
// @param msg {string} commit message
// @param options {object} optional, all (bool) and amend (bool)
// @param cb {function} callback, receives err
git.prototype.commit = function(msg, options, cb){
  this.repo.commit(msg, options, cb);
}

// syncs a repo with a remote branch
// @param remote {string} remote branch, default: origin
// @param branch {string} local branch, default: master
// @param cb {function} callback
git.prototype.pull = function(remote, branch, cb){
  this.repo.sync(remote, branch, cb);
}

// syncs a repo with a remote branch
// @param remote {string} remote branch, default: origin
// @param branch {string} local branch, default: master
git.prototype.pull_sync = function(remote, branch){
  var remote = remote || 'origin';
  var branch = branch || 'master';
  return shell.exec('cd ' + this.dir + '; git pull ' + remote + ' ' + branch);
}

// adds all unstaged files
// @param cb {function} callback
git.prototype.add_all = function(cb){
  this.repo.add('.', cb);
}
