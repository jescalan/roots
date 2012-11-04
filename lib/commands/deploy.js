var run = require('child_process').exec,
    path = require('path'),
    ncp = require('ncp').ncp,
    colors = require('colors');

var _deploy = function(name){

  // check to see if heroku is installed
  run('which heroku', function(err, out, stderr){
    if (err) {
      console.log("You need to install heroku first. Here's the download page".red)
      setTimeout(function(){ require('open')('https://toolbelt.heroku.com/') }, 700)
    } else {

      // check if there is already a heroku app
      run("git branch -r | grep heroku", function(err,out,stdout){
        if (err) {

          // these all need to be run as a sequence
          var source = path.join(__dirname, '../../templates/heroku');
          var destination = path.normalize(process.cwd());

          ncp(source, destination, function (err) {
            if (err) { return console.error(err); }
            console.log('heroku config files copied...'.grey);
          });

          run("git add Procfile package.json server.js; git commit -am 'heroku config'", function(){
            if (err) { return console.error(err) }
            console.log('comitting heroku config files to git...');
          });

          console.log('creating app on heroku...'.grey);
          if (name == undefined) { name = "" } else { name = name[0] }

          // if not, create a new app and deploy
          // run('heroku create ' + name, function(err, out, stderr){
          //   if (err) { return console.error(err) }
          //   console.log('new heroku app created'.green);
          //   // output the heroku output?
          // });
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