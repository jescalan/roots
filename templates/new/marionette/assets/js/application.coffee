define ['jquery', 'underscore', 'backbone', 'marionette', 'router'], ($, _, Backbone, Marionette, Router) ->
  App = new Backbone.Marionette.Application()

  # add app regions here
  
  App.Models = {}
  App.Views = {}
  App.Collections = {}

  App.Router = Router

  return App
