roots(1) -- a toolkit for quickly building beautiful websites
=============================================================

## SYNOPSIS

`roots` <options>

## DESCRIPTION

Roots exposes a variety of commands for creating, managing, compiling, and deploying websites.

The following commands are available:

  * `new`, `<name>`, --<type>    
  create a new roots project called <name>. <type> can be <express> or <basic>.

  * `compile`, --<no-compress>    
  compile, compress, and minify the project to `public`, adding the option <no-compress> will bypass the compression

  * `watch`    
  watch your project and compile/reload whenever a file is saved. does not work for roots-express or roots-rails

  * `deploy`, `<name>`    
  configure, compile, commit, and deploy your project to heroku

  * `version`    
  print the version of the current roots install

  * `js`, `<command>`, `<option>`    
  exposes bower's interface. type `roots js` for help with bower

  * `plugin`, `<command>`, `<option>`    
  manages plugins. command can be `generate` with an optional flag of `--js` for generate a coffeescript or javascript plugin template. command can be `install` with the option being `username/repo` on github to install a plugin into the /plugins folder

## DOCUMENTATION

Full docs can be found at http://roots.cx

## AUTHOR

Jeff Escalante (http://jenius.me) and contributors
