colors = require 'colors'
roots = require './index'
EventEmitter = require('events').EventEmitter
WebSocket = require('faye-websocket')

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

exports.Print = Print

class TerminalPrinter
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
    console.log '\u0007' # bell sound
    console.error '\n\n------------ ERROR ------------\n\n'.red + err.stack + '\n'

  compiling: =>
    @log('compiling... ', 'grey')

  reload: =>
    @log('done!', 'green')

exports.TerminalPrinter = TerminalPrinter

###*
 * @class This handles notifications that are sent to the browser.
 * @todo Make a way of sending log & debug messaages to the browser.
###
class BrowserPrinter
  constructor: ->
    roots.server.server.on 'upgrade', (request, socket, body) =>
      if WebSocket.isWebSocket(request)
        ws = new WebSocket(request, socket, body)
        ws.on 'open', =>
          # send all the msgs in the queue
          for msg in @msgQueue
            @sendMsg msg

        @sockets.push ws

    roots.print.on 'error', @error
    roots.print.on 'compiling', @compiling
    roots.print.on 'reload', @reload

  ###*
   * All the open sockets.
   * @type {Array}
  ###
  sockets: []

  ###*
   * Holds messages that need to be reprinted when the page is reloaded (like
     errors). So they're kept in this queue until they are irrelevant.
   * @type {Array}
  ###
  msgQueue: []

  ###*
   * Save a msg to the queue
   * @param {Object} msg The message to save.
   * @return {[type]} [description]
  ###
  saveMsg: (msg) ->
    if msg not in @msgQueue
      @msgQueue.push msg

  ###*
   * Send a msg to all listening sockets
   * @param {[type]} msg [description]
   * @return {[type]} [description]
  ###
  sendMsg: (msg) ->
    @sockets.forEach (socket) ->
      socket.send JSON.stringify(msg)
      socket.onopen = null

  compiling: =>
    return if not roots.project.cfg 'livereloadEnabled'
    @sendMsg func: 'compiling'

    # clear the message queue, if there are errors they will be added during
    # this compile
    @msgQueue = []

  reload: =>
    console.log 'reload triggered'
    return if not roots.project.cfg 'livereloadEnabled'
    @sendMsg func: 'reload'
    @sockets = [] # close all the sockets

  error: (err) =>
    msg =
      func: 'error'
      data: err.stack
    @saveMsg msg
    @sendMsg msg

exports.BrowserPrinter = BrowserPrinter
