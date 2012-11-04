var run = require('child_process').exec,
    path = require('path'),
    ncp = require('ncp').ncp,
    async = require('async'),
    roots = require('../roots'),
    colors = require('colors');

var _deploy = function(name){

  // compile project helper fits with async module
  
  var compile_project = function(cb){
    roots.compile_project(function(){ cb(); });
  }

  // check to see if heroku is installed
  run('which heroku', function(err, out, stderr){
    if (err) {

      // if heroku isn't installed, instruct on how to install it

      console.log("You need to install heroku first. Here's the download page".red)
      setTimeout(function(){ require('open')('https://toolbelt.heroku.com/') }, 700)

    } else {

      // check if there is already a heroku app

      run("git branch -r | grep heroku", function(err,out,stdout){
        if (err) {

          // if this app hasn't already been pushed to heroku, set it up,
          // create the heroku app, and push it live

          var copy_files = function(cb){
            var source = path.join(__dirname, '../../templates/heroku');
            var destination = path.normalize(process.cwd());

            ncp(source, destination, function (err) {
              if (err) { return console.error(err); };
              console.log('heroku config files copied...'.grey);
              cb();
            });
          }

          var commit_files = function(cb){
            run("git add Procfile package.json server.js; git commit -am 'heroku config'", function(err){
              if (err) { return console.error(err) };
              console.log('comitting heroku config files to git...'.grey);
              cb();
            });
          }

          var heroku_create = function(cb){
            console.log('creating app on heroku...'.grey);
            if (name.length < 1) { name = "" } else { name = name[0] };

            run('heroku create ' + name, function(err, out){
              if (err) { return console.error(err) };
              var url = out.match(/(http:\/\/.*\/)/)[1]
              console.log('new heroku app created at '.green + url.green);
              cb();
            });
          }

          var heroku_push = function(cb){
            console.log('pushing code to heroku (this may take a few seconds)...'.grey);
            run('git push heroku master', function(err, out){
              if (err) { return console.error(err) };
              console.log('heroku app launched'.grey);
              cb();
            });
          }

          // run the steps in sequence
          async.series([ compile_project, copy_files, commit_files, heroku_create, heroku_push ], function(err){
            if (err) { return console.error(err) };
            console.log('done!'.green)
          });

        } else {

          // if there already is an app, deploy it
          // run("git rev-parse --abbrev-ref HEAD", function(err, out, stdout){
          //   run('git push heroku ' + out, function(err, out, stderr){
          //     if (err) {
          //       console.log('error: '.red + err);
          //     } else {
          //       // need to parse the output to grab the url here if possible
          //       console.log('successfully deployed to heroku'.green);
          //     }
          //   });
          // });
        }
      })
    }
  });

}

module.exports = { execute: _deploy, needs_config: true }