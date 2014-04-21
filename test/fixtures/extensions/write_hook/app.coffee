path = require 'path'

write_prevent = ->
  class WritePrevent
    constructor: ->
      @category = 'writeprevent'

    fs: ->
      extract: true
      detect: (f) -> !!f.relative.match(/prevent_write/)

    compile_hooks: ->
      write: -> false

write_normal = ->
  class WriteNormal
    compile_hooks: ->
      write: -> true

write_custom_path = ->
  class WriteCustomPath
    constructor: -> @category = 'writepath'

    fs: ->
      extract: true
      detect: (f) -> !!f.relative.match(/write_custom_path/)

    compile_hooks: ->
      write: (ctx) =>
        { path: path.join(ctx.roots.root, 'override.html'), content: 'wow overrides' }

write_multiple = ->
  class WriteMultiple
    constructor: -> @category = 'multipath'

    fs: ->
      extract: true
      detect: (f) -> !!f.relative.match(/write_multiple_paths/)

    compile_hooks: ->
      write: (ctx) =>
        [
          { path: path.join(ctx.roots.root, 'multi1.html'), content: 'clone 1' },
          { path: path.join(ctx.roots.root, 'multi2.html'), content: 'clone 2' },
          { path: path.join(ctx.roots.root, 'subdir/multi3.html'), content: 'clone 3' }
        ]

module.exports =
  extensions: [write_prevent(), write_normal(), write_custom_path(), write_multiple()]
