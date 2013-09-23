define ['jquery', 'underscore', 'backbone', 'marionette'], ($, _, Backbone, Marionette) ->

  class Router extends Backbone.Marionette.AppRouter
    appRoutes:
      "": "root"
