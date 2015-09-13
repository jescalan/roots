fs    = require 'fs'
path  = require 'path'
Roots = require '../../lib'

###*
 * Simple wrapper for Roots.clean, emits events and data to the cli.
 *
 * @param  {CLI} cli - event emitter for data to be piped to the cli
 * @param  {Object} args arguments object to be passed to roots fn
 * @return {Promise} a promise for the removed output
###

module.exports = (cli, args) ->
  __track('commands', { name: 'deploy', deployer: args.to })

  if !args.env and fs.existsSync(path.join(args.path, 'app.production.coffee'))
    args.env = 'production'

  project = new Roots args.path, env: args.env

  project.deploy(args)
    .progress (msg) ->
      if typeof msg is 'string' then cli.emit('info', msg)
    .then (res) ->
      cli.emit('success', "deployment to #{res.deployer_name} successful")
      if res.url then cli.emit('success', res.url)
    .catch (err) ->
      cli.emit('err', err)
      throw err
