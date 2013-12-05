fs = require 'fs'
js_yaml = require 'js-yaml'
path = require 'path'

class YAMLParser

  constructor: ->
    @matcher = /^---\s*\n([\s\S]*?)\n?---\s*\n?/

  match: (content) ->
    content.match(@matcher)

  parse: (content, options) ->
    options ?= {}
    front_matter = @match(content)
    if not front_matter then return false
    js_yaml.safeLoad(front_matter[1], options)

  detect: (file, done) ->
    res = false
    stream = fs.createReadStream(file, { encoding: 'utf-8', start: 0, end: 3 })
    stream.on('end', -> done(res))
    stream.on 'data', (data) ->
      if data.split('\n')[0] == "---\n" then res = true

module.exports = new YAMLParser

# What's Going On Here?
# ---------------------
#
# The yaml parser does just about what you would expect it to, parses yaml for the
# purpose of dealing with front matter in dynamic content. The real interesting stuff
# here is in the detect method, which has been super speed-optimized. Here, we stream
# only the first three bytes of a file to figure out if it contains front matter.
#
# This operation takes about 5ms on average, a massive reduction over the previous
# techique, reading the entire file and then analyzing for front matter. This makes
# analysis and detection of dynamic files blazing fast, especially when this is done on
# up to 50 files at a time in parallel.
#
# More info on front matter here: http://jekyllrb.com/docs/frontmatter/
