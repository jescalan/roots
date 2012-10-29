var colors = require('colors');

var _help = function(){
  console.log("");
  console.log("Need some help? Here's what you can do with the roots command line tool:");
  console.log("");

  process.stdout.write("- ");
  process.stdout.write("new `name`: ".bold);
  process.stdout.write("create a new project structure in the current directory\n- ");

  process.stdout.write("compile: ".bold);
  process.stdout.write("compile, compress, and minify to /public\n- ");

  process.stdout.write("watch: ".bold);
  process.stdout.write("watch your project, compile and reload whenever you save\n- ");

  process.stdout.write("deploy `name`: ".bold);
  process.stdout.write("deploy your project to heroku\n- ");

  process.stdout.write("update: ".bold);
  process.stdout.write("update roots if there's a new version\n- ");

  process.stdout.write("version: ".bold);
  process.stdout.write("print the version of your current install\n");

  console.log("");
  console.log("...and by all means check out [docs link] for more help!");
  console.log("");

  // to add:
  // - js (list, search, install)
  // - plugin (generate, install)
}

module.exports = { execute: _help }