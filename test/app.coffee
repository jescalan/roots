# ----------------------------------------
# Project Configuration
# ----------------------------------------

# Files or directories matching any of these will not be compiled
# you can use minimatch syntax in place of a regex for a more dynamic
# matcher.
# https://github.com/isaacs/minimatch for more info

exports.ignore_files = ['_*', 'readme*', 'roots-css', '.git', '.gitignore', '.DS_Store']

# Use this to specify which files are layout files.
# `default` applies to all views. Overrides for specific
# views are possible - the path to the view with the custom
# layout is the key, and the path to the layout is the value.

exports.layouts =
  default: 'layout.jade'
  'special.jade': 'layout2.jade'

# Locals will be made available on every page. They can be
# variables or (coffeescript) functions.

exports.locals =
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

# if true, shows the compile process and page/asset status in the
# terminal when watching and compiling files

exports.debug = false

# coffeescript without closures

exports.coffeescript_bare = true

###

Command line tool basics:
(for more options, see [link to docs])

`roots watch` - watch and compile your project with live reloading
`roots compile` - compile your project to the public folder
`roots deploy [name]` - deploy your project to heroku as 'name'

###                   
