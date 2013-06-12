# roots v2.0.0

exports.ignore_files = ['_*', 'readme*', '.git', '.gitignore', '.DS_Store']

exports.layouts =
  default: 'layout.jade'

exports.locals =
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"
