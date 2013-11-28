roots         = require './index'
colors        = require 'colors'
WebSocket     = require('faye-websocket')
EventEmitter  = require('events').EventEmitter

###*
 * @class This handles notifications that are sent to the browser.
 * @todo Make a way of sending log & debug messaages to the browser.
###
module.exports = class BrowserPrinter
  constructor: ->
    roots.print.on 'error', @error
    roots.print.on 'compiling', @compiling
    roots.print.on 'reload', @reload

  start: ->
    roots.server.server.on 'upgrade', (request, socket, body) =>
      if WebSocket.isWebSocket(request)
        ws = new WebSocket(request, socket, body)
        ws.on 'open', =>
          # send all the msgs in the queue
          for msg in @msgQueue
            @sendMsg msg

        @sockets.push ws

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
    return if not roots.project.conf 'livereloadEnabled'
    @sendMsg func: 'compiling'

    # clear the message queue, if there are errors they will be added during
    # this compile
    @msgQueue = []

  reload: =>
    return if not roots.project.conf 'livereloadEnabled'
    @sendMsg func: 'reload'
    @sockets = [] # close all the sockets

  error: (err) =>
    msg =
      func: 'error'
      data: err.stack
    @saveMsg msg
    @sendMsg msg
