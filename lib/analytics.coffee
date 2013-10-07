Keen = require 'keen.io'
roots = require './index'
global_config = require './global_config'

class Analytics

  constructor: ->
    @keen = Keen.configure
      projectId: '5252fe3d36bf5a4f54000008'
      writeKey: 'd4dff32fa0e23516cf4828d2a71219255efd581f8ab3c1a0cc7081e8b1db62825f83b0b5f9ec6417fd23fb877d082d1d5ce238ddc46d048b8ba6608557e87904a475f2a930e4903fc9872323fc120a4859dfb06919d9052e3b676e863a8f6332c21c5cb58be186457398780475dc62a5'

  disable: ->
    global_config.modify('analytics', 'false')

  enable: ->
    global_config.modify('analytics', 'true')

  disabled: ->
    global_config.get().analytics || false

  track_command: (name, args = 'none') ->
    if @disabled() then return false
    @keen.addEvent 'commands', { name: name, args: args }, (err, res) ->
      if err then roots.print.debug(err)

  track_error: (error) ->
    if @disabled() then return false
    @keen.trackEvent 'errors', { message: error }, (err, res) ->
      if err then roots.print.debug(err)

module.exports = new Analytics
