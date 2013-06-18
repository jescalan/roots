
# Files in this list will not be compiled - minimatch supported

ignore_files: ['_*', 'readme*', '.gitignore', '.DS_Store']
ignore_folders: ['.git']

# Layout file config
# `default` applies to all views. Overrides for specific
# views are possible - the path to the view with the custom
# layout is the key, and the path to the layout is the value.

layouts:
  default: 'layout.jade'
  # 'special.jade': 'layout2.jade'

# Locals will be made available on every page. They can be
# variables or (coffeescript) functions.

locals:
  title: 'Welcome to Roots!'
  title_with_markup: ->
    "<h1 class='title'>#{this.title}</h1>"

# run `roots help` to get help on using the command line tool
