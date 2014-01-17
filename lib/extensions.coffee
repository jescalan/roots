_ = require 'lodash'

###*
 * @class Extensions
 * @classdesc  Responsable for managing roots extensions
###

class Extensions

  constructor: (@roots) ->
    @all = []

  ###*
   * register a roots extension with your project
   * @param  {Object} ext       - extension object/instance
   * @param  {Integer} priority - optional, how early the extension is run
  ###

  register: (ext, priority) ->
    if typeof priority == undefined then return @all.push(ext)
    @all.splice(priority, 0, ext)

  ###*
   * return a given extension's hook, if it exists
   * @param  {String} name - hook name, separated with periods
   * @return {Function}      the hook function if exists, otherwise undefined
  ###

  hooks: (name) ->
    n = name.split('.')
    _.compact(@all.map((e) -> if e[n[0]] && e[n[0]][n[1]] then return e[n[0]][n[1]]))

  ###*
   * remove an extension
   * @param  {String} name - name of the extension you'd like to remove
  ###

  remove: (name) ->
    _.remove(@all, ((i) -> i.name == name))

module.exports = Extensions
