require('colors')

path         = require 'path'
pkg          = require '../../package.json'
ArgParse     = require('argparse').ArgumentParser
EventEmitter = require('events').EventEmitter
util         = require 'util'

###*
 * @class  CLI
 * @classdesc command line interface to sprout
###

class CLI extends EventEmitter

  ###*
   * Creates and sets up the argument parser, then calls the config functions
   * for each of the subcommands.
   *
   * @param {Boolean} debug - if debug is true, arg parse errors throw rather
   *                          than exiting the process.
  ###

  constructor: (opts = {}) ->
    @parser = new ArgParse
      version: pkg.version
      description: pkg.description
      debug: opts.debug ? false
    sub = @parser.addSubparsers()

    $new(sub)
    $watch(sub)
    $compile(sub)
    $tpl(sub)
    $clean(sub)
    $deploy(sub)
    $analytics(sub)

  ###*
   * Parses the arguments, runs the command
   *
   * @param {String|Array} args - a string or array of command line arguments
   * @return {Promise} a promise for the command's results
  ###

  run: (args) ->
    if typeof args is 'string' then args = args.split(' ')
    args = @parser.parseArgs(args)

    fn = require("./#{args.fn}")
    delete args.fn

    try p = fn(@, args)
    catch err then handle_thrown_error.call(@, err)

    return p

  ###*
   * If the cli functiom being executed throws an error rather than a rejected
   * promise, it is handled here rather than crashing roots. In addition, there
   * is very specific handling for how roots extension errors are reported.
   * Extension errors can be nasty and hard to debug, so we try to include as
   * much information as possible for extension authors.
   *
   * @param  {*} err - something that was thrown
  ###

  handle_thrown_error = (err) ->
    if err.constructor.name isnt 'RootsError' then return @emit('err', err)

    text = ""
    text += "EXTENSION ERROR!\n".red.bold
    text += "\n"
    text += "It looks like there was a " + "#{err.name}".bold + " Error.\n"
    text += "Check out " + "http://roots.cx/errors##{err.code} ".bold.blue
    text += "for more help\n"
    text += "\n"
    text += "Reason: ".yellow.bold + err.message
    text += "\n"
    text += "\nOffending Extension:".yellow.bold
    text += "\n"
    text += "Name: ".bold + err.ext.constructor.name + "\n"
    text += "Extension: \n".bold
    text += util.inspect(err.ext, { colors: true, showHidden: true })
    text += "\nPrototype: ".bold
    text += util.inspect(err.ext.constructor.prototype)
    text += "\n"
    text += "\nFull Trace:\n".yellow.bold
    text += err.stack
    text += "\n"

    @emit('err', text)

  ###*
   * @private
  ###

  $new = (sub) ->
    s = sub.addParser 'new',
      aliases: ['init', 'create']
      help: 'Create a new roots project template'

    s.addArgument ['path'],
      help: "Path to initialize your project at"

    s.addArgument ['--template', '--tpl', '-t'],
      help: "The template to use for your project"

    s.addArgument ['--overrides', '-o'],
      type: keyVal
      help: "Pass information directly to the template without answering
      questions. Accepts a quoted comma-separated key-value list, like
      'a: b, c: d'"

    s.setDefaults(fn: 'new')

  $watch = (sub) ->
    s = sub.addParser 'watch',
      help: 'Compile a roots project, serve it, and open it in a browser, then
      recompile when a files changes and refresh the page'

    s.addArgument ['path'],
      nargs: '?'
      defaultValue: process.cwd()
      help: "Path to a project that you would like to watch"

    s.addArgument ['--env', '-e'],
      defaultValue: process.env['NODE_ENV'] or 'development'
      help: "Your project's environment"

    s.addArgument ['--no-open'],
      action: 'storeTrue'
      help: "If present, this command will not automatically open a browser
      window"

    s.addArgument ['--port', '-p'],
      type: Number
      defaultValue: 1111
      help: "Port you want to run the local server on (default 1111)"

    s.addArgument ['--verbose', '-v'],
      action: 'storeTrue'
      help: "Offer more verbose output and compile stats"

    s.setDefaults(fn: 'watch')

  $compile = (sub) ->
    s = sub.addParser 'compile',
      help: 'Compile a roots project'

    s.addArgument ['path'],
      nargs: '?'
      defaultValue: process.cwd()
      help: "Path to a project that you would like to compile"

    s.addArgument ['--env', '-e'],
      defaultValue: process.env['NODE_ENV'] or 'development'
      help: "Your project's environment"

    s.addArgument ['--verbose', '-v'],
      action: 'storeTrue'
      help: "Offer more verbose output and compile stats"

    s.setDefaults(fn: 'compile')

  $tpl = (sub) ->
    main = sub.addParser 'template',
      aliases: ['tpl']
      help: "Manage roots' new project templates"

    sub = main.addSubparsers()

    # add

    s = sub.addParser 'add',
      alises: ['install']
      help: 'Add a new template for future use'

    s.addArgument ['name'],
      help: "What you'd like to name the template"

    s.addArgument ['uri'],
      help: "A git-clone-able url or path for the template"

    s.setDefaults(fn: 'tpl/add')

    # remove

    s = sub.addParser ['remove'],
      help: 'Remove an existing template'

    s.addArgument ['name'],
      help: "Name of the template you'd like to remove"

    s.setDefaults(fn: 'tpl/remove')

    # list

    s = sub.addParser ['list'],
      help: 'List all of the templates you have installed'

    s.setDefaults(fn: 'tpl/list')

    # default

    s = sub.addParser ['default'],
      help: 'Make a certain template your default'

    s.addArgument ['name'],
      help: "Name of the template you'd like to make the default"

    s.setDefaults(fn: 'tpl/default')

    # reset

    s = sub.addParser ['reset'],
      help: 'Reset all existing information about templates'

    s.setDefaults(fn: 'tpl/reset')

  $clean = (sub) ->
    s = sub.addParser 'clean',
      help: 'Remove the output folder from a roots project'

    s.addArgument ['path'],
      nargs: '?'
      defaultValue: process.cwd()
      help: "Path to a project that you'd like to remove the output from"

    s.setDefaults(fn: 'clean')

  $deploy = (sub) ->
    s = sub.addParser 'deploy',
      help: 'Deploy the roots project'

    s.addArgument ['path'],
      nargs: '?'
      defaultValue: process.cwd()
      help: "Path to a project that you'd like to deploy"

    s.addArgument ['-to', '--to'],
      help: "Where to deploy the project to - for example s3, heroku, gh-pages"

    s.addArgument ['--env', '-e'],
      defaultValue: process.env['NODE_ENV']
      help: "Your project's environment"

    s.setDefaults(fn: 'deploy')

  $analytics = (sub) ->
    s = sub.addParser 'analytics',
      help: 'Enable or disable roots\'s built-in analytics'

    s.addArgument ['--disable'],
      action: 'storeTrue'
      help: "Globally disable roots analytics"

    s.addArgument ['--enable'],
      action: 'storeTrue'
      help: "Globally enable roots analytics"

    s.setDefaults(fn: 'analytics')

  ###*
   * A simple csv-like string to object parser. Takes in "foo: bar, baz: quux",
   * and outputs a javascript object.
   *
   * @param {String} str - input string
   * @return {Object} javascript object output
  ###

  keyVal = (str) ->
    str.split(',').reduce (m, i) ->
      s = i.split(':').map((i) -> i.trim())
      m[s[0]] = s[1]; m
    , {}

module.exports = CLI
