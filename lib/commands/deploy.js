var shell = require('shelljs'),
    async = require('async'),
    _ = require('underscore'),
    path = require('path'),
    colors = require('colors'),
    Deployer = require('../deployer');

var _deploy = function(args){

  var custom_adapter;
  for (var k in args){
    if (k !== '_' && k !== '$0') { custom_adapter = k }
  }

  if (custom_adapter){
    try {
      adapter = require(path.join('../deploy_recipes/' + custom_adapter));
    } catch (err) {
      return console.log('deploy adapter not found'.red)
    }
  } else {
    adapter = require('../deploy_recipes/heroku');
  }

  // set name if present
  var name = '';
  if (args._.length > 1) { name = args._[1] }

  // deploy it!
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
