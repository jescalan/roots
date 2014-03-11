ext = ->
  class Fail3
    fs: -> true

module.exports =
  extensions: [ext()]
