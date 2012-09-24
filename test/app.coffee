# ----------------------------------------
# Project Configuration
# ----------------------------------------

# Files in this list will not be compiled -
# you can use a string (exact match) or a regex.

ignore_files = [/^_/, /^readme/i, '.git', '.gitignore']

# Use this to specify which files are layout files.
# `default` applies to all views. Overrides for specific
# views are possible - the path to the view with the custom
# layout is the key, and the path to the layout is the value.

layouts =
  default: 'views/layout.jade'
  # 'views/special.jade': 'views/layout2.jade'

# Locals will be made available on any page. They can be
# variables or (coffeescript) functions.

locals =
  title: 'Welcome to Roots!'
  title_with_markup: =>
    "<h1 class='title'>#{this.title}</h1>"

###

Command line tool basics:
(for more options, see [link to docs])

`roots watch` - watch and compile your project with live reloading
`roots compile` - compile your project to the public folder
`roots deploy [name]` - deploy your project to heroku as 'name'

###                   
