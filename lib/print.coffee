roots = require('./index')

class Print
  log: (text) ->
    console.log text

  debug: (text, color='grey') ->
    if not roots.project.debug then return
    console.log text[color]


module.exports = Print
