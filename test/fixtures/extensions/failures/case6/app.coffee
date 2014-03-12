ext = ->
  class Fail6
    compile_hooks: -> true

module.exports =
  extensions: [ext()]
