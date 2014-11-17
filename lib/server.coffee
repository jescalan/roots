connect = require 'connect'
infestor = require 'infestor'
path = require 'path'
http = require 'http'
open = require 'open'
roots = require './index'

exports.start = (serve_dir) ->
  port = process.env.PORT or 1111
  app = connect()
  if roots.project.conf("mode") is "dev"
    app.use(infestor content: """
      <!-- roots development configuration -->
      <script>var __livereload  = #{roots.project.conf("livereloadEnabled")};
              var __rootsport   = #{port};
              var __rootswsport   = #{roots.project.conf("wsPort") || port};
      </script>
      <script src='/__roots__/main.js'></script>
    """)
    app.use('/__roots__', connect.static(path.resolve(__dirname, 'browser_assets')))

  app.use connect.static(serve_dir)
  app.use connect.logger("dev") if roots.project.conf("debug")
  server = exports.server = http.createServer(app).listen(port)
  open "http://localhost:" + port  if roots.project.conf("open") is true
  roots.print.log "server started on port " + port, "green"
