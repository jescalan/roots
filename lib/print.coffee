roots         = require './index'
colors        = require 'colors'
WebSocket     = require('faye-websocket')
EventEmitter  = require('events').EventEmitter

###*
 * This class handles reporting and notifying the user. Currently it just
   prints stuff to the console, but in the future it will manage advanced
   reporting to a Web-UI (or could be extended to do so).
 * @todo Add generic error page when index.html couldn't be compiled.
###
class Print extends EventEmitter
  log: (text, color='') ->
    @emit 'log', text, color

  debug: (text, color='grey') ->
    if not roots.project.debug then return
    @emit 'debug', text, color

  error: (err) ->
    @emit 'error', err

  compiling: ->
    @emit 'compiling'

  reload: ->
    @emit 'reload'

exports.Print           = Print
exports.TerminalPrinter = require('./terminal_printer')
exports.BrowserPrinter  = require('./browser_printer')
