class Static

  constructor: ->
    @fs =
      category: 'static'
      extract: true
      detect: (-> true)

module.exports = Static
