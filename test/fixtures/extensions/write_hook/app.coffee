path = require 'path'

write_prevent = ->
  class WritePrevent
    constructor: -> @category = 'writeprevent'

    fs: ->
      category: @category
      extract: true
      detect: (f) -> !!f.relative.match(/prevent_write/)

    compile_hooks: ->
      write: (ctx) => ctx.category != @category

write_normal = ->
  class WriteNormal
    compile_hooks: ->
      write: -> true

write_custom_path = ->
  class WriteCustomPath
    constructor: -> @category = 'writepath'

    fs: ->
      category: @category
      extract: true
      detect: (f) -> !!f.relative.match(/write_custom_path/)

    compile_hooks: ->
      write: (ctx) =>
        if ctx.category == @category
          { path: path.join(ctx.roots.config.output_path(), 'override.html'), content: 'wow overrides' }
        else
          true

write_multiple = ->
  class WriteMultiple
    constructor: -> @category = 'multipath'

    fs: ->
      category: @category
      extract: true
      detect: (f) -> !!f.relative.match(/write_multiple_paths/)

    compile_hooks: ->
      write: (ctx) =>
        if ctx.category == @category
          [
            { path: path.join(ctx.roots.config.output_path(), 'multi1.html'), content: 'clone 1' },
            { path: path.join(ctx.roots.config.output_path(), 'multi2.html'), content: 'clone 2' }
          ]
        else
          true

module.exports =
  extensions: [write_prevent(), write_normal(), write_custom_path(), write_multiple()]
