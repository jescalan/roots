var run = require('child_process').exec,
    path = require('path'),
    fs = require('fs'),
    shell = require('shelljs'),
    async = require('async'),
    roots = require('../roots'),
    colors = require('colors'),
    name = null;

var _deploy = function(input_name){

  name = input_name;

  if (!shell.which('heroku')) {
    console.log("You need to install heroku first. Here's the download page".red)
    setTimeout(function(){ require('open')('https://toolbelt.heroku.com/') }, 700)
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

// 
// @api private
// utility functions
// 

function compile_project(cb){
  roots.compile_project(function(){ cb(); });
}

// this should push from current branch probably => "git rev-parse --abbrev-ref HEAD"
function heroku_push(cb){
  console.log('pushing code to heroku (this may take a few seconds)...'.grey);

  run('git push heroku master', function(err, out){
    if (err) { return console.error(err) };
    console.log('heroku app launched'.grey);
    cb();
  });
}

function commit_files(cb){
  run("git add .; git commit -am 'compress and deploy'", function(err){
    if (err) { return console.error(err) };
    console.log('comitting heroku config files to git...'.grey);
    cb();
  });
}

function copy_files(cb){
  var source = path.join(__dirname, '../../templates/heroku') + "/*";
  var destination = process.cwd();
  shell.cp('-rf', source, destination);
  console.log('heroku config files copied...'.grey);
  cb();
}

function heroku_create(cb){
  console.log('creating app on heroku...'.grey);
  if (name.length < 1) { name = "" } else { name = name[0] };

  run('heroku create ' + name, function(err, out){
    if (err) { return console.error(err) };
    var url = out.match(/(http:\/\/.*\/)/)[1]
    console.log('new heroku app created at '.green + url.green);
    cb();
  });
}

function done(err){
  if (err) { return console.error(err) };
  console.log('done!'.green)
}