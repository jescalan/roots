ext = ->
  class Fail10
    constructor: -> throw 'wow'

module.exports =
  extensions: [ext()]
