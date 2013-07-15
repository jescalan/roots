colors = require("colors")
_help = ->
  process.stdout.write """
  	Need some help? Here's a list of all available commands (preceded by `roots`):

  	- #{"new `name`:".bold} create a new project structure in the current directory
  	- #{"compile:".bold} compile, compress, and minify to /public
  	- #{"watch:".bold} watch your project, compile and reload whenever you save
  	- #{"deploy `name`:".bold} deploy your project to heroku
  	- #{"version:".bold} print the version of your current install

  	- #{"pkg list:".bold} list the components you have installed
  	- #{"pkg search `name`:".bold} search for a component
  	- #{"pkg install `name`:".bold} install a component
  	- #{"pkg uninstall `name`:".bold} uninstall a component
  	- #{"pkg update `name`:".bold} update a component to the latest version
  	- #{"pkg info `name`:".bold} more info about a component

  	- #{"plugin generate:".bold} generates a roots plugin template
  	- #{"plugin install `username/repo`:".bold} installs a plugin from a github repo

  	...and by all means check out " + "http://roots.cx".green + " for more help!
  """

module.exports = execute: _help
