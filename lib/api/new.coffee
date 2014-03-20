path           = require 'path'
fs             = require 'fs'
{EventEmitter} = require('events')
exec           = require('child_process').exec
nodefn         = require 'when/node'
sprout         = require 'sprout'
global_config  = require '../global_config'
_              = require 'lodash'

class New extends EventEmitter

  constructor: (@roots) ->
    @base_url = 'https://github.com/roots-dev/base.git'

  exec: (opts) ->
    @path = opts.path || throw new Error('missing path')
    @template = opts.template || global_config().get('default_template')
    @options = opts.options

    # if sprout list doesn't contain roots-base
    if not _.contains(sprout.list(), 'roots-base')
      sprout.add(name: 'roots-base', url: @base_url)
        .catch((err) => @emit('error', err))
        .tap(=> @emit('template:base_added'))
        .then(=> init.call(@))
    else
      init.call(@)

    return @

  # @api private

  init = ->
    sprout.init(template: @template, path: @path, options: @options)
      .tap(=> @emit('template:created'))
      .then(=> if has_deps.call(@) then install_deps.call(@))
      .done((=> @emit('done', @path)), ((err) => @emit('error', err)))

  has_deps = ->
    fs.existsSync(path.join(@path, 'package.json'))

  install_deps = ->
    @emit('deps:installing')
    nodefn.call(exec, "cd #{@path} && npm install")
      .tap(=> @emit('deps:finished'))

module.exports = New

###

What's Going On Here?
---------------------

The 'new' class handles the creation of roots templates. It exposes an event emitter, but it's internal methods operate entirely via promises to keep the internal code clean and expose hooks to each part of the process.

The main method, exec, will check to see if the user has any templates installed. If not, it will add the base template, which is the roots default, then continue. If there are already templates, it will continue, assuming the user has used roots before. It will then initialize the template through sprout and return a promise for when it has finished.

The second, has_deps is a simple method that checks to see if the project has a package.json and therefore dependencies that need to be installed. It returns a boolean.

Finally, install_deps will jump into the project and run `npm install`. Throughout the process, events are emitted at times where it might be useful to be able to hook into  the process via the public API.

To see a sample implementation, check out commands/new.coffee to see how you can hook into the events.

###
