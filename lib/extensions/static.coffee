class Static

  constructor: ->
    @category = 'static'
  
    @fs =
      extract: true
      detect: (-> true)

module.exports = Static
