module.exports = ->

  class TestExtension

    constructor: ->
      @category = 'test'

    fs: ->
      category: @category
      extract: true
      ordered: true
      detect: (f) ->
        if f.relative.match(/foobar/) then true else false

    compile_hooks: ->
      before_file: (ctx) =>
        if ctx.category == @category
          ctx.roots.emit('before_file', ctx.path)
      after_file: (ctx) =>
        if ctx.category == @category
          ctx.roots.emit('after_file', ctx.path)
      before_pass: (ctx) =>
        if ctx.file.category == @category
          ctx.file.roots.emit('before_pass', ctx.file.path)
      after_pass: (ctx) =>
        if ctx.file.category == @category
          ctx.file.roots.emit('after_pass', ctx.file.path)
      write: (ctx) =>
        if ctx.category != @category then return true
        ctx.roots.emit('write', ctx.path)
        false

    category_hooks: ->
      after: (ctx, category) ->
        ctx.roots.emit('after_category', ctx.path)    
