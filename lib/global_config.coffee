Configstore = require 'configstore'
pkg         = require '../package.json'

###*
 * Interface for interacting with the roots global config options
 * Docs here: https://github.com/yeoman/configstore#documentation
 *
 * @return {Object} configstore api
###

module.exports = ->
  new Configstore "#{pkg.name}-v#{pkg.version.split('.')[0]}",
    package_manager: 'bower'
    default_template: 'roots-base'
    analytics: true
