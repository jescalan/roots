ignore_files: ['_*', 'readme*', '.git', '.gitignore', '.DS_Store']

layouts:
  default: 'layout.jade'

locals:
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

folder_config:
  assets: 'assets'
  views: 'layouts'
