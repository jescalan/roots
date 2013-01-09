var run = require('child_process').exec,
    path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    async = require('async'),
    _ = require('underscore'),
    roots = require('../roots'),
    colors = require('colors'),
    name = null;

var _deploy = function(input_name){

  var deployer = new Deployer(adapter);
  deployer.compile_project = function(cb){ roots.compile_project(function(){ cb(); }) };

  // if the command line tool isn't installed...
  if (!shell.which(deployer.cli_name)) {
    console.log("You need to install " + adapter + " first. Here's the download page".red)
    setTimeout(function(){ require('open')(adapter.download_url) }, 700); // open needs to be cross platform
  } else {
    // if there's already a heroku app, push to it
    if (shell.exec('git branch -r | grep heroku').output !== '') {
      async.series([ compile_project, commit_files, heroku_push ], done);
    // otherwise, create a new app then push
    } else {
      async.series([ compile_project, copy_files, commit_files, heroku_create, heroku_push ], done);
    }
  }
}

module.exports = { execute: _deploy, needs_config: true }