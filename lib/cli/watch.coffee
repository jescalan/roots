open   = require 'open'
node   = require 'when/node'
Roots  = require '../../lib'
Server = require '../local_server'

###*
 * Wrapper for the roots watch function, implementation of the local server
 * and compile/reload/error events that are sent to it. The gist:
 *
 * - Starts the server at the given (or default) port
 * - Binds start, done, and error events to functions that emit to the cli and
 *   trigger browser actions through the server
 * - Bind an event such that the first time it finishes compiling, it opens the
 *   server in your browser (unless prevented with options)
 * - Returns the server and watcher objects so they can be closed.
 *
 * @param  {CLI} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Object} contains 'server' and 'watcher' keys
###

module.exports = (cli, args) ->
  __track('commands', name: 'watch')

  project = new Roots args.path,
    env: args.env
    verbose: args.verbose
    no_open: args.no_open

  app  = new Server(project)
  port = process.env.port or args.port
  res = { project: project }

  project.on('start', -> on_start(cli, app, res.server, project.config.verbose))
  project.on('done', -> on_done(cli, app, res.server))
  project.on('error', (err) -> on_error(cli, app, res.server, err))

  process.on 'SIGINT', ->
    cli.emit('err_exit', 'watcher cancelled')

  project.watch()
    .then (w) ->
      res.watcher = w
      res.server = app
      node.call(app.start.bind(app), port)
    .yield(res)

###*
 * Emit an error to the CLI and sends it to the server to display in-browser
 *
 * @private
 * @param  {CLI} cli - cli instance
 * @param  {Object} server - server instance
 * @param  {*} err - the error that happened
###

on_error = (cli, server, active, err) ->
  err = Error(err)
  if 'stack' in err then err = err.stack
  cli.emit('err', err)
  console.log('\u0007')
  if active then server.show_error(err)

###*
 * When a change has been detected, notifies the cli and browser that a compile
 * has begun.
 *
 * @private
 * @param  {CLI} cli - cli instance
 * @param  {Object} server - server instance
###

on_start = (cli, server, active, verbose) ->
  cli.emit('inline', 'compiling... '.grey)
  if verbose then cli.emit('data', '')
  if active then server.compiling()

###*
 * When a compile has finished, notifies the CLI and reloads the browser.
 *
 * @private
 * @param  {CLI} cli - cli instance
 * @param  {Object} server - server instance
###

on_done = (cli, server, active) ->
  cli.emit('data', 'done!'.green)
  if active then server.reload()
