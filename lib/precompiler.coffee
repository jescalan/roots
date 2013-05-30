jade = require "jade"
fs = require "fs"
util = require "util"
path = require "path"
_ = require "underscore"
mkdirp = require "mkdirp"
async = require 'async'
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
  fs.writeFileSync output_path, ""
  files = _.map(fs.readdirSync(
    path.join(process.cwd(), root)),
    (f) -> path.basename f, ".jade"
  )
  settings =
    inline: false
    debug: false
    namespace: "templates"
    window: false
    source: root
    output: output_path
    templates: files

  precompile settings, process.cwd()



###
Namespacer(settings)
Description: Creates a Namespacer instance for processing namespace data

settings:
  "namespace": String(Required), namespace object when including templates to browser
  "templates": Array(Required), names of templates to be precompiled
###

class Namespacer
  
  ###
  constructor
  Description: Bind settings to object
  ###
  constructor: (settings) ->
    if settings.namespace? then @groupNamespace = settings.namespace
    else return 'Error: \'namespace\' is not configured'
    
    if settings.templates? then @templates = settings.templates
    else return 'Error: \'templates\' is not configured'
    
    if settings.skiproot? then @skiproot = settings.skiproot
    console.log @skiproot

    if @groupNamespace? and @templates?
      @namespaces = []
      @result = []
      @init()

  init: ->
    async.auto({
      checkGroupNamespace: (callback) -> @checkGroupNamespace(callback)
      checkTemplateNamespaces: (callback) -> @checkTemplateNamespaces(callback)
      createNamespaces: ['checkGroupNamespace', 'checkTemplateNamespaces', (callback) ->
        @createNamespaces(callback)
      ]
    }, (err) ->
      if err?
        return err
      else
        return [null, @result]
    )
    
  ###  
  checkGroupNamespace
  Description: Checks group namespace if needed to be splitted
  ###
  checkGroupNamespace : (callback) ->
    # Checks if needed to split namespace
    if @groupNamespace.indexOf('.') > 0
      @splitNamespace(@groupNamespace, true)
      callback(null)
    else
      @namespaces.push(@groupNamespace)
      callback(null)
  
  ###
  checkTemplateNamespaces
  Description: Checks template namespaces if needed to be splitted
  ###
  checkTemplateNamespaces : (callback) ->
    counter = 0
    
    next = ->
      counter++
      if counter is @templates.length
        arr = []
        for i in [0...@namespaces.length]
          unless arr.indexOf(@namespaces[i]) > 0
            arr.push(@namespaces[i])
          if i is @namespaces.length-1
            @namespaces = arr
            callback(null)
          
    for templateName in @templates
      if templateName.indexOf('/') > 0
        @splitNamespace(templateName)
        next()
      else next()
  

  ###
  createNamespaces
  Description: Prepends required namespace declarations for the browser
  ###
  createNamespaces : (callback) ->

    # Get the maximum index for group namespaces in the namespaces array
    groupNamespaceLength = (@groupNamespace).split('.').length  
  
    # Appends the group namespace declarations
    for g in [0...groupNamespaceLength]
      if g > 0 or not @skiproot
        @result.push "window.#{@namespaces[g]} = window.#{@namespaces[g]} || {};"
    
    if groupNamespaceLength is @namespaces.length
      callback null
    else 
      for t in [groupNamespaceLength...@namespaces.length]
        @result.push "#{@groupNamespace}.#{@namespaces[t]} = #{@groupNamespace}.#{@namespaces[t]} || {};"
        if t is @namespaces.length-1
          callback null
          
  ###
  splitNamespace(name, isGroupNamespace)
  Description: Helper, splits each string and adds it into the 'namespaces' array for later processing

  Params:
    name: Namespace name
    isGroupNamespace: boolean value to determine if the current iteration is for group
  ###
  splitNamespace: (name, isGroupNamespace) ->
    arr = name.split(/\.|\//) # Split template into array

    # Determine the maximum depth to compile
    if isGroupNamespace then max = arr.length else max = arr.length - 1

    @namespaces.push arr[0] # Push base namespace

    str = arr[0] # Set base namespace

    for i in [1...max]
      str += ".#{arr[i]}" # Appends additional levels of namespacing
      @namespaces.push str








###
Precompiler(groupSettings)
Description: Creates a Precompiler instance for executing precompiling work

settings:
  "namespace": String(Required), namespace object when including templates to browser
  "source": String(Required), relative path to source directory
  "output": String, relative path to output directory
  "templates": Array(Required), names of templates to be precompiled
  "compileDebug": Boolean(default: false), whether to compile Jade debugging
  "inline": Boolean(default: false), whether to inline Jade runtime functions

function callback(err, res) {}
(Optional) For Javascript API. If specified "res" will be the String of compiled templates
of this group.

Note: Either one or both of "callback"/"output" must be present, or there will be no output
channel and the module will throw an error.
###
class Precompiler
  ###
  Binds settings, checks for dependencies and throw errors
  ###
  constructor: (groupSettings) ->
    @settings = groupSettings

    if @settings.source
      @settings.source = path.normalize(globalSettings.dir + '/' + @settings.source)
    else
      throw 'ERR: No source directory defined for ' + groupSettings.namespace

      @settings.output = path.normalize(globalSettings.dir + '/' + @settings.output)


  ###
  getNamespaces()
  Description: get and return all the namespace declarations
  ### 
  getNamespaces: (cb) ->
    Namespacer @settings, (err, res) =>
      if err? then throw err
      else
        cb(res.join('\n') + '\n')

  ###
  compile()
  Description: Flow control and execution for the compilation
  ###
  compile: ->
    @getNamespaces (namespaces) =>

      {templates, inline, helpers, output} = @settings
      buf = []
      
      buf.push "(function(){"

      buf.push namespaces if namespaces isnt false

      buf.push @helpers() if helpers isnt false and inline isnt true

      for template in @settings.templates
        buf.push @compileTemplate(template).toString()
      
      buf.push "})();"

      buf = buf.join("")

      buf = compressor(buf, 'js')

      if output?
        fs.writeFileSync @settings.output, buf
        console.log ('Saved and Uglified').bold + ':' + output if @settings.verbose

  ###
  compileTemplate()
  Description: Compiles individual templates and returns them to compile()
  ###
  compileTemplate : (template) ->
    {source, namespace, compileDebug, inline} = @settings

    templateNamespace = template.replace(/\//g, '.') # Replaces '/' with '.'

    if @settings.verbose
      console.log "Compiling #{namespace}.#{templateNamespace} from #{source+template}"

    sourceFile = source + template + '.jade'
    data = fs.readFileSync(sourceFile, 'utf8')

    namespace + '.' + templateNamespace + ' = ' + jade.compile(data, { compileDebug: compileDebug || false, inline: inline || false, client: true }) + ';\n'

  ###
  helpers()
  Description: Gets Jade's helpers and combines them into string
  ###
  helpers: ->
    # Get Jade helpers
    attrs = jade.runtime.attrs.toString().replace(/exports\./g,'')
    escape = jade.runtime.escape.toString()
    rethrow = jade.runtime.rethrow.toString()

    if @settings.compileDebug
      obj = """
        var jade = {
          attrs: attrs,
          escape: escape,
          rethrow: rethrow
        };\n
      """
      [attrs, escape, rethrow, obj].join('\n')
    else
      obj = """
        var jade = {
          attrs: attrs,
          escape: escape
        };\n
      """
      [attrs, escape, obj].join('\n')


extend = (main, sub) ->
  for prop of sub
    main[prop] = sub[prop] if sub[prop]?
  main

# Global settings
globalSettings = {}

###
precompile(settings, dir)
Description: Main precompile function

Params:
  settings(object): Global settings object for tmpl-precompile
    "verbose": Boolean(default:false), if should output compile info on console
    "relative": Boolean(default:true), if paths to each template is relative to settings file
  dir(string): Main execution directory
###
precompile = (settings,dir) ->
  globalSettings = settings
  globalSettings.dir = dir

  precompiler = new Precompiler(settings)
  precompiler.compile()

