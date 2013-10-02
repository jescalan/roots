path = require 'path'
fs = require 'fs'
roots = require '../index'
yaml_parser = require '../utils/yaml_parser'

class DynamicContentExtension

  compile_hook: (deferred) ->
    # only parse out dynamic content on last compile pass
    parse_dynamic_content.call(@fh) if @adapters.length == @index
    deferred.resolve(@)

  parse_dynamic_content = ->

    front_matter_string = yaml_parser.match(@contents)
    if !front_matter_string then return false

    # set up variables
    @dynamic_locals = {}

    # load variables from front matter
    front_matter = yaml_parser.parse(@contents, filename: @path)

    for k of front_matter
      @dynamic_locals[k] = front_matter[k]

    # if layout is present, set the layout and single post url
    if front_matter.layout
      @layout_path = path.resolve(path.dirname(@path), front_matter.layout)
      @layout_contents = fs.readFileSync(@layout_path, "utf8")
      @dynamic_locals.url = @path.replace(roots.project.rootDir, '').replace(/\..*$/, ".html")

    # remove the front matter
    @contents = @contents.replace(front_matter_string[0], '')

module.exports = DynamicContentExtension
