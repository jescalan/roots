var shell = require('shelljs'),
    async = require('async'),
    _ = require('underscore'),
    colors = require('colors'),
    Deployer = require('../deployer');

var _deploy = function(opts){

  // test for custom deploy adapter
  var custom_adapter;
  opts.forEach(function(option, i){
    if (option.match(/--/)){
      custom_adapter = option.replace(/--/,'');
      opts.splice(i)
    }
  });

  if (custom_adapter){
    try {
      adapter = require('../deploy_recipes/' + custom_adapter);
    } catch (err) {
      return console.log('deploy adapter not found'.red)
    }
  } else {
    adapter = require('../deploy_recipes/heroku');
  }

  // set name if present
  var name = '';
  if (opts.length > 0) { name = opts.shift() }

  // set username if present
  var username = '';
  if (opts.length > 0) { username = opts.shift() }

  // deploy it!
  var d = new Deployer(adapter, name, username);
  _.bindAll(d);

  var deploy_steps = [
    d.check_install_status,
    d.check_credentials,
    d.compile_project,
    d.add_config_files,
    d.commit_files,
    d.create_project,
    d.push_code
  ];

  async.series(deploy_steps, function(err){
    if (err) { return console.error(err); }
    console.log('done!'.green);
  });
};

module.exports = { execute: _deploy, needs_config: true };
