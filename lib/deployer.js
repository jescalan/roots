
// Template class for deploy recipes

function Deployer(adapter){
  this.adapter = adapter;
  this.cli_name = adapter.cli_name;
  this.add_shell_method = function(name){ add_method(adapter, name); };

  // template methods
  this.add_shell_method('check_install_status');
  this.add_shell_method('check_credentials');
  this.add_shell_method('compile_project');
  this.add_shell_method('add_config_files');
  this.add_shell_method('commit');
  this.add_shell_method('create_project');
  this.add_shell_method('push_code');

}

function add_method(adapter, name){
  Deployer.prototype[name] = adapter[name] == undefined ? function(){} : adapter[name];
}

module.exports = Deployer;