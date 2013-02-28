# ----------------------------------------
# Project Configuration
# ----------------------------------------

# Files in this list will not be compiled - minimatch supported

exports.ignore_files = ['_*', 'readme*', '.git', '.gitignore', '.DS_Store']

# Layout file config
# `default` applies to all views. Overrides for specific
# views are possible - the path to the view with the custom
# layout is the key, and the path to the layout is the value.

exports.layouts =
  default: 'layout.jade'
  # 'special.jade': 'layout2.jade'

# Locals will be made available on every page. They can be
# variables or (coffeescript) functions.

exports.locals =
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

# If you are working with a client-side js framework that would benefit
# from precompiled templates, set this variable to the location of a folder
# that contains your templates. they will be precompiled to public/js/templates.js
# and made available under window.templates if you load the templates.js script.

# exports.templates = 'views/templates'