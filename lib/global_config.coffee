Configstore = require 'configstore'
pkg         = require '../package.json'
os          = require 'os'
path        = require 'path'

###*
 * Interface for interacting with the roots global config options
 * Docs here: https://github.com/yeoman/configstore#documentation
 *
 * @return {Object} configstore api
###

module.exports = ->
  new Configstore "#{pkg.name}-v#{pkg.version.split('.')[0]}",
    default_template: 'roots-base'
    analytics: true

module.exports.dir = path.join(os.homedir(), '.config/roots')
