rimraf = require 'rimraf'
nodefn = require 'when/node'

###*
 * @class Clean
 * @classdesc removes a roots project's output folder
###

class Clean
  constructor: (@roots) ->

  ###*
   * Very simple function, just removed the output path and returns a promise
   * @return {Promise} promise for the removed output folder
  ###

  exec: ->
    __track('api', { name: 'clean' })
    nodefn.call(rimraf, @roots.config.output_path())

module.exports = Clean
