roots         = require './index'
colors        = require 'colors'
WebSocket     = require('faye-websocket')
EventEmitter  = require('events').EventEmitter

module.exports = class TerminalPrinter
  constructor: ->
    roots.print.on 'log', @log
    roots.print.on 'debug', @debug
    roots.print.on 'error', @error
    roots.print.on 'compiling', @compiling
    roots.print.on 'reload', @reload

  log: (text, color) =>
    if color isnt ''
      console.log text[color]
    else
      console.log text

  debug: (text, color) =>
    @log text, color

  error: (err) =>
    err = new Error(err) if typeof err is "string"

    console.log '\u0007' # bell sound
    console.error '\n\n------------ ERROR ------------\n\n'.red + err.stack + '\n'

  compiling: ->
    process.stdout.write('compiling... '.grey)

  reload: =>
    @log('done!', 'green')
