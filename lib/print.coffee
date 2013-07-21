colors = require 'colors'
roots = require './index'

class Print
  log: (text, color='') ->
    console.log text[color]

  debug: (text, color='grey') ->
    if not roots.project.debug then return
    console.log text[color]

  error: (err) ->
    console.log '\u0007' # bell sound
    console.error '\n\n------------ ERROR ------------\n\n'.red + err.stack + '\n'

module.exports = Print
