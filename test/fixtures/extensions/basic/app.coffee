class DynamicContent

  constructor = (@opts) ->
    @category = 'dynamic'

  fs:
    # category: 'dynamic' # default: @category
    extract: true # default: false
    ordered: true # default: false
    detect: (f) -> true

  compile_hooks:
    # category: 'dynamic' # default: @category || 'all'
    before_file: (ctx) ->
    after_file: (ctx) ->
    before_pass: (ctx) ->
    after_pass: (ctx) ->

  category_hooks:
    # category: 'dynamic' # default: @category || 'all'
    after: (ctx, category) ->

module.exports =

  extensions: [new DynamicContent()]
