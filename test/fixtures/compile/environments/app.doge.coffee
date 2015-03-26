test_extension    = require './test_extension'
another_extension = require './another_extension'

module.exports =
  output: 'public'
  ignores: ['dev_file.html']
  dump_dirs: ['test']
  debug: true
  live_reload: false
  open_browser: false
  locals:
    data: [
      user:
        name: 'alfred'
        location: 'new york'
      values: [3, 4]
    ]
  server:
    clean_urls: false
    exclude: ['another file']
    routes: {"**": "home.html", "work/**/*": "work.html"}
  extensions: [test_extension(test: 'app.doge.coffee')]
