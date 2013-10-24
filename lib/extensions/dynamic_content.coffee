require 'coffee-script'

path = require 'path'
fs = require 'fs'
roots = require '../index'
yaml_parser = require '../utils/yaml_parser'
LayoutsExtension = require './layouts'


class DynamicContentExtension

  compile_hook: (ctx, deferred) ->
    # only parse out dynamic content on last compile pass
    parse_dynamic_content(ctx.fh) if ctx.adapters.length == ctx.index
    deferred.resolve(ctx)

  ###*
   * Provides compatibility with the Dynamic Content extension.
   * Pushes the front matter variables and content for dynamic content
   * as locals so they are available in html templates.
   * @public
  ###

  set_dynamic_locals: (ctx) ->
    ctx.dynamic_locals.contents = ctx.contents
    
    # get an array of folder the content is nested in
    nested_folders = ctx.path.replace(roots.project.rootDir,'').split(path.sep)
    nested_folders.pop()
    nested_folders.shift()

    # add path to the locals for tracing
    ctx.dynamic_locals._categories = nested_folders

    # make sure all folders are represented on the site object in locals
    roots.project.locals.site ?= {}
    tmp = roots.project.locals.site

    for folder, i in nested_folders
      tmp[folder] ?= []
      if i == nested_folders.length-1 then tmp[folder].push(ctx.dynamic_locals)
      ctx.local_pointer = tmp = tmp[folder]

  ###*
   * parses out the dynamic content, adds to dynamic locals,
   * removes front matter from the template
   * @private
  ###

  parse_dynamic_content = (fh) ->

    # parse front matter
    front_matter_string = yaml_parser.match(fh.contents)
    if !front_matter_string then return false

    # set up variables
    fh.dynamic_locals = {}

    # load variables from front matter
    front_matter = yaml_parser.parse(fh.contents, filename: fh.path)
    for k of front_matter
      fh.dynamic_locals[k] = front_matter[k]

    # if layout is present, set the layout locals and single post url
    # this provides integration with the layouts extension
    if front_matter.layout
      (new LayoutsExtension).set_layout_locals(fh, front_matter.layout, true)
      fh.dynamic_locals.url = fh.path.replace(roots.project.rootDir, '').replace(/\..*$/, ".html")

    # remove the front matter
    fh.contents = fh.contents.replace(front_matter_string[0], '')

module.exports = DynamicContentExtension
