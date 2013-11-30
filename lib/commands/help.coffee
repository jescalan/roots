colors = require 'colors'
roots = require '../index'

_help = ->
  roots.print.log("""
    Need some help? Here's a list of common commands (preceded by `roots`):
    #{'new <name> [ --<template> ]'.bold} create a new project in the current directory
    #{'template <command>'.bold}          manage templates
    #{'compile [ --no-compress ]'.bold}   compile, compress, and minify to /public
    #{'watch [ --no-open ]'.bold}         watch your project, compile & reload when you save
    #{'deploy [ <name> ] [ --<service> ]'.bold} deploy your project to a service
    #{'clean'.bold}                       remove the compiled files
    #{'version|-v'.bold}                  print the version of your current install
    #{'pkg [ <command> ]'.bold}           manage packages used in the current project
    #{'plugin <command>'.bold}            manage plugins

    And by all means check out #{'http://roots.cx'.green} and the man page for more help!
    """
  )

module.exports = execute: _help 
