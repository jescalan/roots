{EventEmitter} = require('events')
fs = require 'fs'
Config = require './config'

class Roots extends EventEmitter

  constructor: (@root) ->
    if not fs.existsSync(@root) then throw new Error("path does not exist")
    @config = new Config(@)

  @new: (name, p, cb) ->
    n = new (require('./api/new'))(@)
    n.exec(name, p).on('done', (root) => if cb then cb(new @(root)))
    return n

  compile: ->
    (new (require('./api/compile'))(@)).exec()
    return @

  watch: ->
    (new (require('./api/watch'))(@)).exec()
    return @

module.exports = Roots

###

What's Going On Here?
---------------------

Welcome to the main entry point to roots! Through this very file, all the magic happens. Roots' code is somewhat of a work of art for me, something I strive to make as beautiful as functional, and consequently something I am hardly ever totally happy with because as soon as I learn or improve, I start seeing more details that could be smoothed out.

Anyways, let's jump into it. This file exposes the main roots class and public API to roots. Everything within roots is loaded as lazily as possible, and uses dependency injection to share context between the different classes that make up roots. This allows a pretty significant speed boost, since for example, none of the deps for watch are loaded. The only code loaded is the code you need, which not only is good for performance, but also forces a very clean and separated API design. You can find all the individual method classes in the api folder.

All roots' public API methods expose event emitters. Compile and watch expose the same emitter, while new exposes a slightly different one.

The new class method is a bit of an anomaly. Since you do not technically have a roots project if you are running new, it is exposed as a class method and can optionally be an alternate constructor as well -- if you pass in a callback, it will not only initialize your project, but also pass you back a fully loaded roots instance configured to your new project.

The compile and watch methods do more or less what you would expect - compile the project, and watch the project for changes then compile. The compile function runs once off, while the watch function will hang until you exit the process somehow.

###
