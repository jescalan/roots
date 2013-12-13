nodefn  = require 'when/node/function'
http    = require 'http'
connect = require 'connect'

module.exports = class
  constructor: (@root) ->

  start: (port) ->
    app     = connect().use(connect.static(@root + "/public"))
    @server = http.createServer(app)
    nodefn.call(@server.listen.bind(@server), port).yield(@server)

  close: ->
    @server.close()
    delete @server

###

What is this all about?
--------------------
* Creates a simple static web server that serves up the public compiled dir
* The constructor allows you to pass any root directoy
* Exposes two public API methods
  * start - returns a promise
  * stop - sync

###
