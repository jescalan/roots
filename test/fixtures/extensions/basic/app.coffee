class TestExtension

  fs: ->
    category: 'test'
    extract: true
    ordered: true
    detect: (path) ->
      if path.match(/foobar/) then true else false

  compile_hooks: ->
    before_file: (ctx) =>
      if ctx.category == @fs().category
        console.log 'before file hook for ' + ctx.path
    after_file: (ctx) =>
      if ctx.category == @fs().category
        console.log 'after file hook for ' + ctx.path
    before_pass: (ctx) =>
      if ctx.file.category == @fs().category
        console.log 'before pass hook for ' + ctx.file.path
    after_pass: (ctx) =>
      if ctx.file.category == @fs().category
        console.log 'after pass hook for ' + ctx.file.path

  category_hooks: ->
    after: (ctx, category) -> console.log "after category " + category

module.exports =
  extensions: [new TestExtension()]
