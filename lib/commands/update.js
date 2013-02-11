var run = require('child_process').exec,
    colors = require('colors');


var _update = function(){

  // there should be some sort of check for updates as well

  console.log("updating...".yellow);

  run('npm install roots -g', function(err, out, stderr){
    if (err) {
      console.log(out);
      console.log(stderr);
      console.log("don't panic! run `sudo npm install roots -g` and all should be well".red);
    } else {
      console.log("done!".green);
    }
  });

};

module.exports = { execute: _update };
