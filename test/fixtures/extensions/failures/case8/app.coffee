ext = ->
  class Fail8
    category_hooks: -> true

module.exports =
  extensions: [ext()]
