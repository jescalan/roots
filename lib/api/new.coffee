path          = require 'path'
fs            = require 'fs'
W             = require 'when'
nodefn        = require 'when/node'
Sprout        = require '../sprout'
global_config = require '../global_config'
_             = require 'lodash'
npm           = require 'npm'

base_tpl_name = 'roots-base'
base_tpl_url  = 'https://github.com/roots-dev/base.git'

###*
 * Creates a new roots project using a template. If a template is not provided,
 * the roots-base template is used. If the roots-base template has not been
 * installed, that is installed first. Once the template has been created, if it
 * contains a package.json file with dependencies, they are installed. To review
 * the promise chain:
 *
 * - check to see if roots-base is installed
 * - if not, install it, emitting 'template:base_added' when finished
 * - initialize the template with sprout
 * - when finished, emit 'template:created'
 * - check to see if deps are present
 * - if so install them, emit 'deps:installing' before and 'deps:finished' after
 * - at the end, emit 'done' or 'error events', and return a promise
 *
 * @param  {Roots} roots - roots instance
 * @param  {Object} opts - options object
 * @return {Promise} promise for completed new template
###

class New
  constructor: (@Roots) ->

  exec: (opts = {}) ->
    __track('api', { name: 'new', template: opts.template })

    d = W.defer()

    if not opts.path
      return W.reject(new Error('missing path'))

    sprout = Sprout()
    p = path.resolve(opts.path)

    opts =
      locals: opts.overrides ? {}
      
    pkg = path.join(p, 'package.json')

    W.resolve(_.contains(sprout.templates, base_tpl_name))
      .then (res) ->
        if not res
          sprout.add(base_tpl_name, base_tpl_url)
            .tap(-> d.notify('base template added'))
      .then(-> sprout.init(base_tpl_name, p, opts))
      .tap(-> d.notify('project created'))
      .then(-> if fs.existsSync(pkg) then install_deps(d, pkg))
      .done((=> d.resolve(new @Roots(p))), d.reject.bind(d))

    return d.promise

  ###*
   * Uses npm to install a project's dependencies.
   *
   * @private
   * @return {Promise} a promise for installed deps
  ###

  install_deps = (d, pkg) ->
    d.notify('dependencies installing')

    nodefn.call(npm.load.bind(npm), require(pkg))
      .then(-> nodefn.call(npm.commands.install, path.dirname(pkg), []))
      .then(-> d.notify('dependencies finished installing'))

module.exports = New
