define ['jquery', 'underscore', 'backbone', 'marionette', 'app'], ($, _, Backbone, Marionette, App) ->
  App.module "Collections", (Collections, App, Backbone, Marionette, $, _) ->
    class Collections.Example extends Backbone.Collection
