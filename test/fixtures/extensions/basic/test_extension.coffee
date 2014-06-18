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
        ctx.roots.emit('before_file', ctx.path)
      after_file: (ctx) =>
        ctx.roots.emit('after_file', ctx.path)
      before_pass: (ctx) =>
        ctx.file.roots.emit('before_pass', ctx.file.path)
      after_pass: (ctx) =>
        ctx.file.roots.emit('after_pass', ctx.file.path)
      write: (ctx) =>
        ctx.roots.emit('write', ctx.path)
        false

    category_hooks: ->
      after: (ctx, category) ->
        ctx.roots.emit('after_category', ctx.path)

    project_hooks: ->
      after: (ctx) ->
        ctx.roots.emit('after_project', ctx.path)
