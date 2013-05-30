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
  root = path.join(global.options.templates, "/")
  output_path = path.normalize("public/js/templates.js")
  mkdirp.sync path.dirname(output_path)

  precompiler = new Precompiler(
    source: path.normalize(process.cwd() + '/' + root)
    output: output_path
    templates: _.map(fs.readdirSync(
      path.join(process.cwd(), root)),
      (f) -> path.basename f, ".jade"
    )
  )
  buf = precompiler.compile()
  buf = compressor buf, 'js'
  fs.writeFileSync output_path, buf


class Precompiler
  constructor: (options = {}) ->
    defaults =
      inline: false
      debug: false
      namespace: "templates"
      source: ''
      output: ''
      templates: undefined

    _.extend @, defaults, options

  ###
  compile()
  Description: Flow control and execution for the compilation
  ###
  compile: ->
    buf = []
    buf.push """
    (function(){
      window.#{@namespace} = window.#{@namespace} || {};
      #{@helpers() if @helpers isnt false and @inline isnt true}
    """

    for template in @templates
      buf.push @compileTemplate(template).toString()

    buf.push '})();'
    return buf.join ''

  ###
  compileTemplate()
  Description: Compiles individual templates and returns them to compile()
  ###
  compileTemplate : (template) ->
    templateNamespace = template.replace(/\//g, '.') # Replaces '/' with '.'
    sourceFile = @source + template + '.jade'
    data = fs.readFileSync(sourceFile, 'utf8')

    "#{@namespace}.#{templateNamespace} = #{jade.compile(data, { compileDebug: @debug || false, inline: @inline || false, client: true })};\n"

  ###
  helpers()
  Description: Gets Jade's helpers and combines them into string
  ###
  helpers: ->
    # Get Jade helpers
    attrs = jade.runtime.attrs.toString().replace(/exports\./g,'')
    escape = jade.runtime.escape.toString()
    rethrow = jade.runtime.rethrow.toString()

    if @debug
      obj = '
        var jade = {
          attrs: attrs,
          escape: escape,
          rethrow: rethrow
        };\n
      '
      [attrs, escape, rethrow, obj].join('\n')
    else
      obj = '
        var jade = {
          attrs: attrs,
          escape: escape
        };\n
      '
      [attrs, escape, obj].join('\n')
