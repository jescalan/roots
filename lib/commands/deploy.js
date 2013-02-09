var shell = require('shelljs'),
    async = require('async'),
    _ = require('underscore'),
    colors = require('colors'),
    Deployer = require('../deployer');

var _deploy = function(name){

  // as soon as other adapters are working, this needs
  // to pull from an option
  var adapter = require('../deploy_recipes/heroku');

  var d = new Deployer(adapter, name);
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
