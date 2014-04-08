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
      optional: ['--no-compress']
      description: 'Compiles the roots project. Optional flag will not compress or minify files.'  
    }, {
      name: 'watch'
      optional: ['dir', '--no-open', '--no-livereload']
      description: 'Watches the given [dir] or current directory and recompiles every time changes are made.'  
    }, {
      name: 'deploy'
      required: ['deployer']
      optional: ['file/dir']
      description: 'Deploys the given [file/dir] or by default the output folder via the given [deployer]. See http://ship.io for deployers.'  
    }, {
      name: 'clean'
      description: 'Removes the output folder.'  
    }, {
      name: 'version'
      description: 'Outputs the currently installed version of roots.'  
    }, {
      name: 'template'
      description: 'Manage roots templates. `roots template` for help.'  
    }, {
      name: 'pkg'
      description: 'Utilize a roots-integrated package manager. `roots pkg` for help.'  
    }]
