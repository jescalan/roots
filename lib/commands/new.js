var path = require('path'),
    shell = require('shelljs'),
    run = require('child_process').exec,
    colors = require('colors'),
    current_directory = path.normalize(process.cwd());

var _new = function(commands){

  if (typeof commands[0] === "undefined") {
    return console.error('make sure to pass a name for your project!'.red);
  }

  switch (commands[1]){
    case '--basic':
      var source = path.join(__dirname, '../../templates/new_basic');
      break;
    case '--express':
      var source = path.join(__dirname, '../../templates/new_express');
      break;
    case '--ejs':
      var source = path.join(__dirname, '../../templates/new_ejs');
      break;
    case '--blog':
      var source = path.join(__dirname, '../../templates/new_blog');
      break;
    // case '--backbone':
    //   var source = path.join(__dirname, '../../templates/new_backbone');
    //   break;
    default:
      var source = path.join(__dirname, '../../templates/new');
  }

  var destination = path.join(current_directory, commands[0]);

  shell.cp('-r', source + '/*', destination);
  console.log('\nnew project created at /'.green + commands[0].green + '\n');

  run("git init " + destination, function(err){
    if (err) {
      console.log("You should install git ASAP.".red);
      console.log('Check out http://git-scm.com/ for a quick and easy download\n'.yellow);
    }
  });
};

module.exports = { execute: _new };
