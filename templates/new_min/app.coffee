# ----------------------------------------
# Project Configuration
# ----------------------------------------

exports.ignore_files = ['_*', 'readme*', '.gitignore', '.DS_Store']
exports.ignore_folders = ['.git']

exports.layouts =
  default: 'layout.jade'

exports.locals =
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

# exports.templates = 'views/templates'