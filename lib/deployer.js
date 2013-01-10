var colors = require('colors'),
    shell = require('shelljs'),
    roots = require('./roots');


// Template class for deploy recipes

function Deployer(adapter, name){
  this.adapter = adapter;
  this.name = name;
  this.add_shell_method = function(name){ add_method(adapter, name); };

  // template methods
  this.add_shell_method('check_credentials');
  this.add_shell_method('add_config_files');
  this.add_shell_method('create_project');
  this.add_shell_method('push_code');

}

module.exports = Deployer;

// 
// A couple functions that are the same across all adapters (currently)
// 

// perhaps this show throw an error instead
Deployer.prototype.check_install_status = function(cb){
  if (!shell.which(adapter.cli_name)){
    console.log("You need to install " + adapter + " first. Here's the download page".red)
    setTimeout(function(){ require('open')(adapter.download_url) }, 700);
  } else {
    cb();
  }
}

Deployer.prototype.compile_project = function(cb){
  roots.compile_project(function(){ cb(); });
  console.log('roots project compiled'.grey);
}

Deployer.prototype.commit_files = function(cb){
  var cmd = shell.exec("git add .; git commit -am 'compress and deploy'");
  console.log(cmd.output); // debug
  console.log('project committed to git'.grey);
  cb();
}

// 
// @api private
// 

function add_method(adapter, name){
  Deployer.prototype[name] = adapter[name] == undefined ? function(){} : adapter[name];
}