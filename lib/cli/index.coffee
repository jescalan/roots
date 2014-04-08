help = require './help'
fs = require 'fs'
path = require 'path'
EventEmitter = require('events').EventEmitter

module.exports = cli = new EventEmitter

module.exports.execute = (args, pkg) ->
  # `roots -v`, `roots --version`, or `roots version`
  if args.version or args._[0] is 'version'
    return cli.emit('data', pkg.version)

  # `roots` or `roots help`
  if not args._.length or args._[0] is 'help'
    return cli.emit('data', help())

  # other commands
  cmds = fs.readdirSync(path.join(__dirname)).map (d) ->
    return path.basename(d).split('.')[0];

  try cmd = require(path.join(__dirname, args._[0]))
  catch err
    return cli.emit('err', "\n❗  command not found\n".red + "try `roots help`\n".grey)

  cmd(args, cli)
