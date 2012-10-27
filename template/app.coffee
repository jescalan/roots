# ----------------------------------------
# Project Configuration
# ----------------------------------------

# Files in this list will not be compiled -
# you can use a string (exact match) or a regex.

exports.ignore_files = ['_*', 'readme*', 'roots-css', '.git', '.gitignore', '.DS_Store']

# Use this to specify which files are layout files.
# `default` applies to all views. Overrides for specific
# views are possible - the path to the view with the custom
# layout is the key, and the path to the layout is the value.
# The second line is an example of a custom layout.

exports.layouts =
  default: 'layout.jade'
  # 'special.jade': 'layout2.jade'

# Locals will be made available on every page. They can be
# variables or (coffeescript) functions.

exports.locals =
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

# Names of the views and assets folder. Don't recommend
# changing these, but if you have some other naming convention,
# go for it. Make sure you change the actual folders as well.

exports.folder_config =
  assets: 'assets'
  views: 'views'

# If true, shows the compile process and page/asset status in the
# terminal when watching and compiling files.

exports.debug = false

###

Command line tool basics:
(for more options, see [link to docs])

`roots watch` - watch and compile your project with live reloading
`roots compile` - compile your project to the public folder
`roots deploy [name]` - deploy your project to heroku as 'name'

###                   
