define ['jquery', 'underscore', 'backbone', 'marionette', 'app', 'templates'], ($, _, Backbone, Marionette, App, templates) ->

  class App.Views.Example extends Marionette.ItemView
    getTemplate: -> templates.example
