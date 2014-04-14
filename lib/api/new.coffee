path = require 'path'
fs = require 'fs'
{EventEmitter} = require('events')
exec = require('child_process').exec
nodefn = require 'when/node'
sprout = require 'sprout'
global_config = require '../global_config'
_ = require 'lodash'
npm = require 'npm'

###*
 * @class New
 * @classdesc Uses sprout to create new roots projects
###

class New extends EventEmitter

  constructor: (@roots) ->
    @base_url = 'https://github.com/roots-dev/base.git'

  ###*
   * Main method, given a path to where the project should be and some
     (optional) additional options, creates a new project template. If no
     template is provided, uses the roots default template, which is installed
     if not present. Once the template is created, installs dependencies if a
     package.json is present.
   * @param {Object} opts - Arguments object, takes the following:
   * @param {string} opts.path - path to nonexistant folder where project
     should be
   * @param {string} opts.template - name of the template to use for the
     project
   * @param {Object} opts.options - overrides for template config
   * @param {Object} opts.defaults - default values for template config
  ###

  exec: (opts) ->
    @path = opts.path || throw new Error('missing path')
    @template = opts.template || global_config().get('default_template')
    @overrides = opts.options || {}
    @defaults = opts.defaults || {}

    @pkg = path.join(@path, 'package.json')
    @defaults.name = opts.name

    if not _.contains(sprout.list(), 'roots-base')
      sprout.add(name: 'roots-base', uri: @base_url)
        .catch((err) => @emit('error', err))
        .tap(=> @emit('template:base_added'))
        .then(=> init.call(@))
    else
      init.call(@)

    return @

  ###*
   * Uses sprout.init to create a project template, emits events, and installs
     dependencies if necessary.
   * @private
  ###

  init = ->
    sprout.init
      name: @template
      path: @path
      overrides: @overrides
      defaults: @defaults
    .tap(=> @emit('template:created'))
    .then(=> if has_deps.call(@) then install_deps.call(@))
    .done((=> @emit('done', @path)), ((err) => @emit('error', err)))

  ###*
   * Tests whether a project has a package.json file and therefore needs to
     have dependencies installed.
   * @private
   * @return {Boolean} whether a package.json file exists in the template
  ###

  has_deps = ->
    fs.existsSync(@pkg)

  ###*
   * Uses npm to install a project's dependencies.
   * @private
   * @return {Promise} a promise for installed deps
  ###

  install_deps = ->
    @emit('deps:installing')

    nodefn.call(npm.load.bind(npm), require(@pkg))
      .then(=> nodefn.call(npm.commands.install, path.dirname(@pkg), []))
      .then(=> @emit('deps:finished'))

module.exports = New
