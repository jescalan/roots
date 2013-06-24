var colors = require('colors');

var _help = function(){
  console.log("");
  console.log("Need some help? Here's a list of all available commands (preceded by `roots`):");
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

  process.stdout.write("version: ".bold);
  process.stdout.write("print the version of your current install\n");

  process.stdout.write("\n");
  process.stdout.write("- " + "pkg list: ".bold + "list the components you have installed");
  process.stdout.write("\n");
  process.stdout.write("- " + "pkg search `name`: ".bold + "search for a component");
  process.stdout.write("\n");
  process.stdout.write("- " + "pkg install `name`: ".bold + "install a component");
  process.stdout.write("\n");
  process.stdout.write("- " + "pkg uninstall `name`: ".bold + "uninstall a component");
  process.stdout.write("\n");
  process.stdout.write("- " + "pkg update `name`: ".bold + "update a component to the latest version");
  process.stdout.write("\n");
  process.stdout.write("- " + "pkg info `name`: ".bold + "more info about a component");
  process.stdout.write("\n");

  process.stdout.write("\n");
  process.stdout.write("- " + "plugin generate: ".bold + "generates a roots plugin template");
  process.stdout.write("\n");
  process.stdout.write("- " + "plugin install `username/repo`: ".bold + "installs a plugin from a github repo");
  process.stdout.write("\n");

  console.log("");
  console.log("...and by all means check out " + "http://roots.cx".green + " for more help!");
  console.log("");

};

module.exports = { execute: _help };
