var colors = require('colors');

var _help = function(){
  process.stdout.write(
    "\nNeed some help? Here's a list of all available commands (preceded by `roots`):\n\n" +
    "- " + "new `name`: ".bold + "create a new project structure in the current directory\n" +
    "- " + "compile: ".bold + "compile, compress, and minify to /public\n" +
    "- " + "watch: ".bold + "watch your project, compile and reload whenever you save\n" +
    "- " + "deploy `name`: ".bold + "deploy your project to heroku\n" +
    "- " + "version: ".bold + "print the version of your current install\n\n" +
    "- " + "pkg list: ".bold + "list the components you have installed\n" +
    "- " + "pkg search `name`: ".bold + "search for a component\n" +
    "- " + "pkg install `name`: ".bold + "install a component\n" +
    "- " + "pkg uninstall `name`: ".bold + "uninstall a component\n" +
    "- " + "pkg update `name`: ".bold + "update a component to the latest version\n" +
    "- " + "pkg info `name`: ".bold + "more info about a component\n\n" +
    "- " + "plugin generate: ".bold + "generates a roots plugin template\n" +
    "- " + "plugin install `username/repo`: ".bold + "installs a plugin from a github repo\n\n" +
    "...and by all means check out " + "http://roots.cx".green + " for more help!\n\n"
  );
};

module.exports = { execute: _help };
