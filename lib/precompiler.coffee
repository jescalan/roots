jade = require "jade"
fs = require "fs"
path = require "path"
_ = require "underscore"
mkdirp = require "mkdirp"
minimatch = require "minimatch"
compressor = require './utils/compressor'

# compile jade templates into JS functions for use on the client-side, and
# save it to a specified file

module.exports = ->
  global.options.debug.log 'precompiling templates', 'yellow'
  return false if not global.options.templates?
  template_dir = path.join process.cwd(), global.options.templates
  files = fs.readdirSync(template_dir)

  # make sure to skip ignored files
  ignores = []
  files.map (f) ->
    options.ignore_files.forEach (i) ->
      ignores.push(f) if minimatch(f, i.slice(1))

  precompiler = new Precompiler(
    templates: _.map(
      _.difference(files, ignores),
      (f) -> path.join template_dir, f
    )
  )

  buf = precompiler.compile()
  buf = compressor buf, 'js'

  # TODO: make output path configurable
  output_path = path.normalize("#{options.output_folder}/js/templates.js")
  mkdirp.sync path.dirname(output_path)
  fs.writeFileSync output_path, buf


class Precompiler
  
  # deals with setting up the variables for options
  # @param {Object} options = {} an object holding all the options to be
  # passed to the compiler. 'templates' must be specified.
  # @constructor
  
  constructor: (options = {}) ->
    defaults =
      include_helpers: true
      inline: false
      debug: false
      namespace: 'templates'
      templates: undefined # an array of template filenames

    _.extend @, defaults, options

  
  # loop through all the templates specified, compile them, and add a wrapper
  # @return {String} the source of a JS object which holds all the templates
  # @public
  
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

  
  # compile individual templates
  # @param {String} template the full filename & path of the template to be compiled
  # @return {String} source of the template function
  # @private
  
  compileTemplate: (template) ->
    templateNamespace = path.basename(template, '.jade').replace(/\//g, '.') # Replaces '/' with '.'
    data = fs.readFileSync(template, 'utf8')
    data = jade.compile(data, { compileDebug: @debug || false, inline: @inline || false, client: true })
    return "#{@namespace}.#{templateNamespace} = #{data};\n"

  
  # Gets Jade's helpers and combines them into string
  # @return {String} source of Jade's helpers
  # @private
  
  helpers: ->
    buf = [
      jade.runtime.attrs.toString().replace(/exports\./g,''),
      jade.runtime.escape.toString()
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

    return buf.join('\n')
