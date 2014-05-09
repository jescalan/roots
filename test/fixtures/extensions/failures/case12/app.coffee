ext = ->
  class Fail8
    project_hooks: -> true

module.exports =
  extensions: [ext()]
