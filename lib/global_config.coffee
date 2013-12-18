pkg = require '../package.json'

module.exports = ->
  new (require 'configstore') "#{pkg.name}-v#{pkg.version.split('.')[0]}",
    package_manager: 'bower'
    default_template: 'base'
