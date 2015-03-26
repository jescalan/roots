test_extension    = require './test_extension'
another_extension = require './another_extension'

module.exports = 
  output: 'public'
  ignores: ['doge_file.html']
  dump_dirs: ['views', 'assets']
  debug: false
  live_reload: true
  open_browser: true
  locals:
    data: [
      user:
        name: 'joe'
        age: 45
      values: [1, 2]
    ]
  server:
    clean_urls: true
    exclude: ['some_file']
    routes: {"**": "index.html"}
  extensions: [
    test_extension(test: 'app.coffee'),
    another_extension(test: 'another extension')
  ]
