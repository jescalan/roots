jade = require "jade"
fs = require "fs"
util = require "util"
path = require "path"
_ = require "underscore"
mkdirp = require "mkdirp"
compressor = require './utils/compressor'

# @api private
# precompiles jade templates to javascript functions
# then writes them to a file.
module.exports = ->
  global.options.debug.log "precompiling templates", "yellow"
  return false if typeof global.options.templates is "undefined"
  template_dir = path.join process.cwd(), global.options.templates

  precompiler = new Precompiler(
    templates: _.map(
      fs.readdirSync(template_dir),
      (f) -> path.join template_dir, f
    )
  )

  buf = precompiler.compile()
  buf = compressor buf, 'js'

  # TODO: make output folder dynamic
  output_path = path.normalize("public/js/templates.js")
  mkdirp.sync path.dirname(output_path)
  fs.writeFileSync output_path, buf


class Precompiler
  ###*
   * deals with setting up the variables for options
   * @param {Object} options = {} an object holding all the options to be
     passed to the compiler. 'templates' must be specified.
  ###
  constructor: (options = {}) ->
    defaults =
      include_helpers: true
      inline: false
      debug: false
      namespace: "templates"
      templates: undefined # an array of template filenames

    _.extend @, defaults, options

  ###*
   * loop through all the templates specified, compile them, and add a wrapper
   * @return {String} the source of a JS object which holds all the templates
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
    return buf.join ''

  ###*
   * compile individual templates
   * @param {String} template the full filename & path of the template to be compiled
   * @return {String} source of the template function
  ###
  compileTemplate: (template) ->
    templateNamespace = path.basename(template, '.jade').replace(/\//g, '.') # Replaces '/' with '.'
    data = fs.readFileSync(template, 'utf8')
    data = jade.compile(data, { compileDebug: @debug || false, inline: @inline || false, client: true })
    return "#{@namespace}.#{templateNamespace} = #{data};\n"

  ###*
   * Gets Jade's helpers and combines them into string
   * @return {String} source of Jade's helpers
  ###
  helpers: ->
    obj = [
      jade.runtime.attrs.toString().replace(/exports\./g,''),
      jade.runtime.escape.toString()
    ]

    if @debug
      obj.push jade.runtime.rethrow.toString()

    obj.push ["""
    var jade = {
      attrs: attrs,
      escape: escape #{
        if @debug then ',\n  rethrow: rethrow' else ''
      }
    };
    """]

    return obj.join('\n')
