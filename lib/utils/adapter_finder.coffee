_ = require 'underscore'
adapters = require '../adapters'

###*
 * Given a list of file extensions, return matching adapters that will
 * compile a file with the extensions provided
 * @param {array} extensions - array of strings listing extensions, no dot.
 * @return {array} array of adapters that can be used to compile the file
 * @private
###

module.exports = (extensions) ->
  matching_adapters = []
  extensions.reverse().forEach (ext) =>
    _.each adapters, (adp) ->
      matching_adapters.push(adp) if adp.settings.file_type is ext

  return matching_adapters
