ext = ->
  class Fail4
    fs: ->
      detect: -> true

module.exports =
  extensions: [ext()]
