path = require 'path'

ext = ->
  class CategoryScopeTest
    constructor: ->
      @category = 'scope_test'

    fs: ->
      extract: true
      detect: (f) ->
        path.basename(f.relative) is 'active'

    compile_hooks: ->
      after_file: (ctx) ->
        ctx.roots.emit('after_file', "[1] #{ctx.file.relative}")

    category_hooks: ->
      after: (ctx, category) ->
        ctx.roots.emit('after_category', "[1] #{category}")

ext2 = ->
  class CategoryOverrideTest
    constructor: ->
      @category = 'overridden'

    fs: ->
      category: 'scope_override'
      extract: true
      detect: (f) ->
        path.basename(f.relative) is 'scope_override'

    compile_hooks: ->
      category: 'scope_override'
      after_file: (ctx) ->
        ctx.roots.emit('after_file', "[2] #{ctx.file.relative}")

    category_hooks: ->
      category: 'scope_override'
      after: (ctx, category) ->
        ctx.roots.emit('after_category', "[2] #{category}")

ext3 = ->
  class CategoryOverrideTest2
    constructor: ->
      @category = 'not_overridden'

    fs: ->
      extract: true
      detect: (f) ->
        path.basename(f.relative) is 'failed_override'

    compile_hooks: ->
      category: 'failed_override'
      after_file: (ctx) ->
        ctx.roots.emit('after_file', "[3] #{ctx.file.relative}")

    category_hooks: ->
      after: (ctx, category) ->
        ctx.roots.emit('after_category', "[3] #{category}")

ext4 = ->
  class HookLevelCategories

    fs: ->
      category: 'hook_level'
      extract: true
      detect: (f) ->
        path.basename(f.relative) is 'hook_level'

    compile_hooks: ->
      category: 'hook_level'
      after_file: (ctx) ->
        ctx.roots.emit('after_file', "[4] #{ctx.file.relative}")

    category_hooks: ->
      category: 'hook_level'
      after: (ctx, category) ->
        ctx.roots.emit('after_category', "[4] #{category}")

ext5 = ->
  class AllCategories

    compile_hooks: ->
      after_file: (ctx) ->
        ctx.roots.emit('after_file', "[5] #{ctx.file.relative}")

    category_hooks: ->
      after: (ctx, category) ->
        ctx.roots.emit('after_category', "[5] #{category}")

module.exports =
  extensions: [ext(), ext2(), ext3(), ext4(), ext5()]
