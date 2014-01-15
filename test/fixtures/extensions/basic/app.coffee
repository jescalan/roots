class DynamicContent

  constructor = (@opts) ->
    @category = 'dynamic'

  fs:
    # category: 'dynamic' # default: @category
    extract: true # default: false
    detect: (f) -> true

  order: 'before' # default 'parallel'

  compile_hooks:
    # category: 'dynamic' # default: @category || 'all'
    before: (ctx) ->
    after: (ctx) ->

  category_hooks:
    # category: 'dynamic' # default: @category || 'all'
    after: (ctx, category) ->

module.exports =

  extensions: [new DynamicContent()]
