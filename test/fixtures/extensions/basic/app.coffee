class TestExtension

  constructor = (@opts) ->
  
  category: 'test'

  fs:
    # category: 'dynamic' # default: @category
    extract: true # default: false
    ordered: true # default: false
    detect: (path) ->
      console.log 'detect function'
      return false

  compile_hooks:
    # category: 'dynamic' # default: @category || 'all'
    before_file: (ctx) ->
      console.log 'before file hook'
    after_file: (ctx) ->
      console.log 'after file hook'
    before_pass: (ctx) ->
      console.log 'before pass hook'
    after_pass: (ctx) ->
      console.log 'after pass hook'

  category_hooks:
    # category: 'dynamic' # default: @category || 'all'
    after: (ctx, category) ->
      console.log "after " + category

module.exports =

  extensions: [new TestExtension()]
