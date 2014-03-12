ext = ->
  class Fail9
    compile_hooks: ->
      write: -> 10

module.exports =
  extensions: [ext()]
