define ['jquery', 'underscore', 'backbone', 'marionette', 'router'], ($, _, Backbone, Marionette, Router) ->
  App = new Backbone.Marionette.Application()

  App.Router = Router

  return App
