w       = require 'when'
http    = require 'http'
connect = require 'connect'

module.exports = class
  constructor: (@root) ->

  start: (port=1111) ->
    d       = w.defer()
    app     = connect().use(connect.static(@root + "/public"))
    @server = http.createServer(app)

    @server.listen port, (err) ->
      return d.reject(err) if err
      d.resolve @server

    d.promise

  close: ->
    @server.close()
    delete @server

###
What is this all about?

* Creates a simple static web server that serves up the public compiled dir
* The constructor allows you to pass any root directoy
* Exposes two public API methods
  * start - returns a promise
  * stop - sync
