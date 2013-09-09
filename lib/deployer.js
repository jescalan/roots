var colors = require('colors'),
    shell = require('shelljs'),
    path = require('path'),
    roots = require('./index');

// Template class for deploy recipes

function Deployer(adapter, name){
  this.adapter = adapter;
  this.name = name.length < 1 ? "" : name;
  this.add_shell_method = function(name){ add_method(adapter, name); };

  // template methods
  this.add_shell_method('check_install_status');
  this.add_shell_method('check_credentials');
  this.add_shell_method('add_config_files');
  this.add_shell_method('create_project');
  this.add_shell_method('push_code');
}

module.exports = Deployer;

// A couple functions that are the same across all adapters (currently)

Deployer.prototype.compile_project = function(cb){
  roots.project.compress = true;
  shell.rm('-rf', roots.project.paths('public'));
  roots.compile_project(roots.project.rootDir, function(){ cb(); });
};

Deployer.prototype.commit_files = function(cb){
  roots.print.log('committing to git', 'grey');
  var cmd = shell.exec("git add .; git commit -am 'compress and deploy'", { silent: true });
  if (cmd.code > 0) throw cmd;
  cb();
};

// @api private

function add_method(adapter, name){
  Deployer.prototype[name] = typeof adapter[name] === "undefined" ? function(cb){cb();} : adapter[name];
}
