pkg = require '../package.json'

###*
 * Interface for interacting with the roots global config options
 * Docs here: https://github.com/yeoman/configstore#documentation
 * @return {Object} configstore api
###

module.exports = ->
  new (require 'configstore') "#{pkg.name}-v#{pkg.version.split('.')[0]}",
    package_manager: 'bower'
    default_template: 'roots-base'
