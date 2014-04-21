module.exports = ->

  ###*
   * @class
   * @classdesc This extension is run last, scoops all remiaining files into
   * a "static" category to be copied over directly.
  ###

  class Static

    constructor: ->
      @category = 'static'

    fs: ->
      extract: true
      detect: (-> true)
