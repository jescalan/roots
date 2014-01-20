class TestExtension

  constructor: (@opts = {}) ->
    @category = 'test'

    @fs =
      extract: true
      ordered: true
      detect: (path) ->
        if path.match(/foobar/) then true else false

    @compile_hooks =
      before_file: (ctx) -> console.log 'before file hook'
      after_file: (ctx) -> console.log 'after file hook'
      before_pass: (ctx) -> console.log 'before pass hook'
      after_pass: (ctx) -> console.log 'after pass hook'

    @category_hooks =
      after: (ctx, category) -> console.log "after " + category

module.exports =

  extensions: [new TestExtension()]
