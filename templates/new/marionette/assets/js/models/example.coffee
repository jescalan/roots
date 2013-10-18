define ['jquery', 'underscore', 'backbone', 'marionette', 'app'], ($, _, Backbone, Marionette, App) ->
  App.module "Models", (Models, App, Backbone, Marionette, $, _) ->
    class Models.Example extends Backbone.Model
      # if this model has a related form, use a form schema
      # https://github.com/powmedia/backbone-forms
