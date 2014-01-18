roots = require './index'
colors = require 'colors'
WebSocket = require('faye-websocket')

class TerminalPrinter
  constructor: ->
    roots.print.on 'log', @log
    roots.print.on 'debug', @debug
    roots.print.on 'error', @error
    roots.print.on 'compiling', @compiling
    roots.print.on 'reload', @reload

  log: (text, color) ->
    if color isnt ''
      console.log text[color]
    else
      console.log text

  debug: (text, color) ->
    @log text, color

  error: (err) =>
    message = @normalize_error err
    console.log '\u0007' # bell sound
    console.error '\n\n------------ ERROR ------------\n\n'.red + message + '\n'

  normalize_error: (err) ->
    if err instanceof Error
      message = err.stack
    else if typeof err is 'string'
      message = err
    else
      message = err.toString()
      if message is '[object Object]'
        message = JSON.stringify err
    message

  compiling: ->
    process.stdout.write('compiling... '.grey)

  reload: =>
    @log('done!', 'green')

module.exports = TerminalPrinter
