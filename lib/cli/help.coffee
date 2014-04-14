antimatter = require 'anti-matter'

module.exports = ->
  antimatter
    title: 'Roots Usage'
    options: { width: 65, color: 'blue' }
    commands: [{
      name: 'new'
      required: ['name']
      optional: ['dir', '--template-name']
      description: 'Creates a new roots project called [name] in [dir]. If [dir] is not provided, project is created in the current directory. The [--template-name] option lets you choose to initialize with an installed template.'
    }, {
      name: 'compile'
      optional: ['dir']
      description: 'Compiles the roots project at the given [dir] or current directory.'
    }, {
      name: 'watch'
      optional: ['dir', '--no-open']
      description: 'Watches the given [dir] or current directory, opens a browser to a local server (unless [--no-open] is passed), and recompiles every time changes are made.'
    }, {
      name: 'deploy'
      required: ['deployer']
      optional: ['file/dir']
      description: 'Deploys the given [file/dir] or by default the output folder via the given [deployer]. See http://ship.io for deployers.'
    }, {
      name: 'clean'
      optional: ['dir']
      description: 'Removes the output folder from a roots project in [dir] or current directory'
    }, {
      name: 'version'
      description: 'Outputs the currently installed version of roots.'
    }, {
      name: 'tpl'
      description: 'Manage roots templates. `roots tpl` for help.'
    }]
