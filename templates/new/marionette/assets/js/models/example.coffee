define ['jquery', 'underscore', 'backbone', 'marionette', 'app'], ($, _, Backbone, Marionette, App) ->

  class App.Models.Example extends Backbone.Model

    # if this model has a related form, use a form schema
    # https://github.com/powmedia/backbone-forms
