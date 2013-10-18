define ['jquery', 'underscore', 'backbone', 'marionette', 'app', 'templates'], ($, _, Backbone, Marionette, App, templates) ->
  App.module "Views", (Views, App, Backbone, Marionette, $, _) ->
    class Views.Example extends Marionette.ItemView
      getTemplate: -> templates.example
