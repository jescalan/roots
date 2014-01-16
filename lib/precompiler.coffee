jade = require 'jade'
fs = require 'fs'
path = require 'path'
_ = require 'underscore'
mkdirp = require 'mkdirp'
minimatch = require 'minimatch'
readdirp = require 'readdirp'
roots = require './index'
compressor = require './utils/compressor'
W = require('when')

# compile jade templates into JS functions for use on the client-side, and
# save it to a specified file

module.exports = ->
  deferred = W.defer()

  roots.print.debug 'precompiling templates', 'yellow'
  return false if not roots.project.templates?
  template_dir = path.join(roots.project.rootDir, roots.project.templates)

  return false unless fs.existsSync(template_dir)

  options =
    root: template_dir
    directoryFilter: roots.project.ignore_folders
    fileFilter: roots.project.ignore_files

  readdirp options, (err, res) ->
    precompiler = new Precompiler(
      templates: _.map(res.files, (f) -> f.fullPath)
    )

    try
      buf = precompiler.compile()
      buf = compressor buf, 'js'
    catch e
      deferred.reject(e)

    output_path = roots.project.path 'precompiledTemplateOutput'
    mkdirp.sync path.dirname(output_path)
    fs.writeFileSync output_path, buf
    deferred.resolve()

  deferred.promise

class Precompiler

  ###*
   * deals with setting up the variables for options
   * @param {Object} options = {} an object holding all the options to be
     passed to the compiler. 'templates' must be specified.
   * @constructor
  ###
  constructor: (options = {}) ->
    defaults =
      include_helpers: true
      inline: false
      debug: false
      namespace: 'templates'
      templates: undefined # an array of template filenames

    _.extend @, defaults, options

  ###*
   * loop through all the templates specified, compile them, and add a wrapper
   * @return {String} the source of a JS object which holds all the templates
   * @public
  ###
  compile: ->
    buf = ["""
    (function(){
      window.#{@namespace} = window.#{@namespace} || {};
      #{@helpers() if @include_helpers isnt false and @inline isnt true}
    """]

    for template in @templates
      buf.push @compileTemplate(template).toString()

    buf.push '})();'
    buf.join ''

  ###*
   * compile individual templates
   * @param {String} template the full filename & path of the template to be
     compiled
   * @return {String} source of the template function
   * @private
  ###
  compileTemplate: (template) ->
    basePath = template.split(path.join(roots.project.rootDir, roots.project.templates)+"/")[1]
    templateNamespace = basePath.split('.jade')[0]

    data = fs.readFileSync(template, 'utf8')
    data = jade.compile(
      data,
      {compileDebug: @debug || false, inline: @inline || false, client: true}
    )
    "#{@namespace}['#{templateNamespace}'] = #{data};\n"

  ###*
   * Gets Jade's helpers and combines them into string
   * @return {String} source of Jade's helpers
   * @private
  ###
  helpers: ->
    # jade has a few extra helpers that aren't exported. we should probably
    # figure out a way to pull all of runtime.js
    nulls = `function nulls(val) { return val != null && val !== '' }`
    joinClasses = `function joinClasses(val) { return Array.isArray(val) ? val.map(joinClasses).filter(nulls).join(' ') : val; }`

    buf = [
      jade.runtime.attrs.toString().replace(/exports\./g,''),
      jade.runtime.escape.toString(),
      nulls.toString(),
      joinClasses.toString(),
      ";__ROOTS_ENV='#{process.env["ROOTS_ENV"]}';"
    ]

    buf.push jade.runtime.rethrow.toString() if @debug

    buf.push """
    var jade = {
      attrs: attrs,
      escape: escape #{
        if @debug then ',\n  rethrow: rethrow' else ''
      }
    };
    """

    buf.join('\n')
