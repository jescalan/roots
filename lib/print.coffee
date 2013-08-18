colors = require 'colors'
roots = require './index'

###*
 * This class handles reporting and notifying the user. Currently it just
   prints stuff to the console, but in the future it will manage advanced
   reporting to a Web-UI (or could be extended to do so).
###
class Print
  log: (text, color='') ->
    if color isnt ''
      console.log text[color]
    else
      console.log text

  debug: (text, color='grey') ->
    if not roots.project.debug then return
    console.log text[color]

  error: (err) ->
    console.log '\u0007' # bell sound
    console.error '\n\n------------ ERROR ------------\n\n'.red + err.stack + '\n'

module.exports = Print
