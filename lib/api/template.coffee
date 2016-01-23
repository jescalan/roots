fs            = require 'fs'
_             = require 'lodash'
W             = require 'when'
nodefn        = require 'when/node'
Sprout        = require '../sprout'
global_config = require '../global_config'

sprout        = Sprout()

###*
 * Adds a template to sprout. Delegates directly to sprout's API.
 *
 * @todo  prepend templates with 'roots-''
 * @param {Object} args - can contain keys 'name', 'uri'
 * @return {Promise} a promise for the added template
###

exports.add = (args) ->
  __track('api', { name: 'template-add', template: args.name })
  sprout.add(args.name, args.uri, _.omit(args, 'name', 'uri'))
    .then -> "template '#{args.name}' added"

###*
 * Removes a template from sprout. Delegates directly to sprout's API.
 *
 * @param {Object} args - must contain key 'name'
 * @return {Promise} promise for removed template
###

exports.remove = (args = {}) ->
  __track('api', { name: 'template-remove', template: args.name })

  if not args.name
    return W.reject(new Error('please provide a template name to remove'))

  sprout.remove(args.name)
    .then -> "template '#{args.name}' removed"
    .catch (err) -> W.reject(err)

###*
 * List all templates. Delegates directly to sprout's API.
 * @param {Object} args - can contain key `pretty`
 * @return {String} a string colored and formatted for the terminal
###

exports.list = (args = {}) ->
  __track('api', { name: 'template-list' })

  templates = _.keys(sprout.templates)
  if args.pretty
    "\n- #{templates.join('\n- ')}\n"
  else
    return templates


###*
 * Set the default template used with roots new when one isn't supplied.
 *
 * @param  {Object} args - must contain key 'name'
 * @return {Promise} a promise that your template is the default
###

exports.default = (args = {}) ->
  __track('api', { name: 'template-default', template: args.name })

  if not args.name
    return W.reject(new Error('please provide a template name'))

  if not _.includes(_.keys(sprout.templates), args.name)
    return W.reject(new Error "you do not have this template installed")

  config = global_config()
  config.set('default_template', args.name)

  W.resolve("default template set to '#{args.name}'")

###*
 * Resets the global config file and removes all installed sprout templates.
 *
 * @param  {Boolean} override - do not confirm via stdin if true
 * @return {Promise} a promise for reset templates
 *
 * istanbul ignore next
###

exports.reset = (override) ->
  __track('api', { name: 'template-reset' })

  deferred = W.defer()

  if override
    remove_roots_config(deferred)
  else
    process.stdout.write 'are you sure? (y/n) '.yellow
    process.stdin.resume()
    process.stdin.setEncoding('utf8')
    process.stdin.on 'data', (txt) ->
      process.stdin.pause()
      txt = txt.trim()
      if txt is 'y' or txt is 'Y' then return remove_roots_config(deferred)
      deferred.reject('reset cancelled')

  return deferred.promise

###*
 * Removes all other templates and global config.
 *
 * @private
 * @param  {Object} deferred - deferred object
 * @return {Promise} promise for finished task
 *
 * istanbul ignore next
###

remove_roots_config = (deferred) ->
  nodefn.call(fs.unlink, global_config().path)
