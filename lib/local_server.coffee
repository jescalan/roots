nodefn  = require 'when/node/function'
http    = require 'http'
connect = require 'connect'

module.exports = class
  constructor: (@root) ->

  start: (port) ->
    app     = connect()
    app.use(@reloadInjector).use(connect.static(@root + "/public"))
    @server = http.createServer(app)
    nodefn.call(@server.listen.bind(@server), port).yield(@server)

  close: ->
    @server.close()
    delete @server

  reloadInjector: (req, res, next) =>
    w         = res.write
    e         = res.end
    injected  = false

    res.write = (buffer, encoding) =>
      res.write = w
      if buffer?
        string = buffer.toString(encoding)
        if ~string.indexOf('<body>')
          @injectLocalScript(string, encoding, res)
          return injected = true

        return res.write(buffer, encoding)
      true

    res.end = (string, encoding) ->
      res.end = e
      res.setHeader('content-length', Buffer.byteLength(res.data, encoding)) if injected
      res.end res.data, encoding

    next()

  injectLocalScript: (string, encoding, res) ->
    res.data = (res.data || '') + string.replace(/<\/body>/, (w) -> "<script>console.log('hello from the server');</script> #{w}")

###

What is this all about?
--------------------
* Creates a simple static web server that serves up the public compiled dir
* The constructor allows you to pass any root directoy
* Exposes two public API methods
  * start - returns a promise
  * stop - sync

###
