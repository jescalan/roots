require "coffee-script"
path = require 'path'
fs = require 'fs'
shell = require 'shelljs'
roots = require './index'

class Adapters
  ###*
   * Generate the array of adapters needed to compile `inputFormat` to
     whatever its outputFormat is. Also, determine the outputExtension. It's a
     little weird to have both these things in one function... eh, so it goes.
   * @param {Array} inputFormat An array of extensions that the source file
     has, in the order which they must be compiled.
   * @return {Array} The first element is the array of adapters, the 2nd is
     the outputExtension (a string)
  ###
  getAdapters: (inputFormat) ->
    asset_adapters = []
    while inputFormat.length > 0
      extension = inputFormat.shift()
      if extension of @adapters
        asset_adapters.push @adapters[extension]
      else
        break

    if inputFormat.length is 0
      outputExtension = asset_adapters[asset_adapters.length - 1].outputFormat
    else
      outputExtension = inputFormat.join '.'

    return [asset_adapters, outputExtension]

  ###*
   * Adds new adapters, overwriting existing adapters that have any of the
     same inputFormats.
   * @param {[type]} adapter [description]
   * @return {[type]} [description]
  ###
  registerAdapter: (adapter) ->
    for inputFormat in adapter.inputFormats
      @adapters[inputFormat] = adapter

  ###*
   * All the adapters that are registered. Each key is a inputFormat
   * @type {Object}
  ###
  adapters: {}

module.exports = Adapters
