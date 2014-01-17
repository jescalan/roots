connect = require("connect")
express = require("express")
colors = require("colors")
path = require("path")
http = require("http")
open = require("open")
roots = require("./index")
rootsBrowserAssets = (req, res, next) ->
  snippet = "<script src=\"/__roots__/main.js\" type=\"text/javascript\"></script>"
  bodyExists = (body) ->
    return false  unless body
    ~body.lastIndexOf("</body>")

  snippetExists = (body) ->
    return true  unless body
    ~body.lastIndexOf(snippet)

  acceptsHtmlExplicit = (req) ->
    accept = req.headers["accept"]
    return false  unless accept
    ~accept.indexOf("html")

  isExcluded = (req) ->
    excludeList = [".woff", ".js", ".css", ".ico"]
    url = req.url
    excluded = false
    return true  unless url
    excludeList.forEach (exclude) ->
      excluded = true  if ~url.indexOf(exclude)

    excluded

  writeHead = res.writeHead
  write = res.write
  end = res.end
  return next()  if not acceptsHtmlExplicit(req) or isExcluded(req)
  res.push = (chunk) ->
    res.data = (res.data or "") + chunk

  res.inject = res.write = (string, encoding) ->
    res.write = write
    if string isnt `undefined`
      body = (if string instanceof Buffer then string.toString(encoding) else string)
      if (bodyExists(body) or bodyExists(res.data)) and not snippetExists(body) and (not res.data or not snippetExists(res.data))
        res.push body.replace(/<\/body>/, (w) ->
          snippet + w
        )
        return true
      else
        return res.write(string, encoding)
    true

  res.end = (string, encoding) ->
    res.writeHead = writeHead
    res.end = end
    result = res.inject(string, encoding)
    return res.end(string, encoding)  unless result
    res.setHeader "content-length", Buffer.byteLength(res.data, encoding)  if res.data isnt `undefined` and not res._header
    res.end res.data, encoding

  next()

exports.start = (serve_dir) ->
  port = process.env.PORT or 1111
  app = express()
  if roots.project.conf("mode") is "dev"
    app.use "/__roots__", connect.static(path.resolve(__dirname, "browser_assets"))
    app.get "/__roots__/conf.json", (req, res) ->
      
      # we could expose a bunch of other stuff, I just don't feel like it right now
      res.send JSON.stringify(livereloadEnabled: roots.project.conf("livereloadEnabled"))

    app.use rootsBrowserAssets
  app.use connect.static(serve_dir)
  app.use connect.logger("dev")  if roots.project.conf("debug")
  server = exports.server = http.createServer(app).listen(port)
  open "http://localhost:" + port  if roots.project.conf("open") is true
  roots.print.log "server started on port " + port, "green"
