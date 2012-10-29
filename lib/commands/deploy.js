var run = require('child_process').exec,
    colors = require('colors');

var _deploy = function(){

  // check to see if heroku is installed
  run('which heroku', function(err, out, stderr){
    if (err) {
      console.log("You need to install heroku first. Here's the download page".red)
      setTimeout(function(){ require('open')('https://toolbelt.heroku.com/') }, 700)
    } else {

      // check if there is already a heroku app
      run("git branch -r | grep heroku", function(err,out,stdout){
        if (err) {
          console.log('creating app on heroku...'.green);
          var name = argv._[1]
          if (name == undefined) { name = "" }

          // if not, create a new app abd deploy
          // run('heroku create ' + name, function(err, out, stderr){
          //   console.log('new heroku app created');
          //   should run `heroku open` here as well
          // });
        } else {

          // if there already is an app, deploy it
          // run("git rev-parse --abbrev-ref HEAD", function(err, out, stdout){
            // run('git push heroku ' + out, function(err, out, stderr){
            // // need to parse the output to grab the url here if possible
            //   console.log('deployed to heroku at (url)');
            // });
          // });
        }
      })
    }
  });

}

module.exports = { execute: _deploy, needs_config: true }