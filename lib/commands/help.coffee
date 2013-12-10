require('colors')

exports.execute = ->
  console.log(
    "\n" +
    "Roots Usage\n".red.bold +
    "-----------\n".bold +

    document_option(
      name: 'new'
      required: ['name']
      optional: ['dir']
      description: 'Creates a new roots project called [name] in [dir]. If [dir] is not provided, project is created in the current directory.'
    ) +

    document_option(
      name: 'compile'
      optional: ['--no-compress']
      description: 'Compiles the roots project. Optional flag will not compress or minify files.'
    ) +

    document_option(
      name: 'watch'
      optional: ['dir', '--no-open', '--no-livereload']
      description: 'Watches the given [dir] or current directory and recompiles every time changes are made.'
    ) +

    document_option(
      name: 'deploy'
      required: ['deployer']
      optional: ['file/dir']
      description: 'Deploys the given [file/dir] or by default the output folder via the given [deployer]. See http://ship.io for deployers.'
    ) +

    document_option(
      name: 'clean'
      description: 'Removes the output folder.'
    ) +

    document_option(
      name: 'version'
      description: 'Outputs the currently installed version of roots.'
    ) +

    document_option(
      name: 'template'
      description: 'Manage roots templates. `roots template` for help.'
    ) +

    document_option(
      name: 'pkg'
      description: 'Utilize a roots-integrated package manager. `roots pkg` for help.'
    ) +

    "\nCheck out https://roots.cx for more docs and tutorials!\n".green
  )

wordwrap = (str, width, brk, cut) ->
  brk = brk || '\n'
  width = width || 75
  cut = cut || false
  if !str then return str
  regex = '.{1,' +width+ '}(\\s|$)' + (if cut then '|.{' +width+ '}|.+$' else '|\\S+?(\\s|$)')
  return str.match( RegExp(regex, 'g') ).join(brk)

document_option = (conf) ->
  res = "\n* ".red
  res += "#{conf.name.bold} "
  res += "#{arg.underline} ".grey for arg in conf.required if conf.required
  res += "[#{arg}] ".grey for arg in conf.optional if conf.optional
  res += "\n"
  res += "#{wordwrap(conf.description, 59, '\n')}"
  res += "\n"
