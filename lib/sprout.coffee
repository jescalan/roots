Sprout        = require 'sprout'
path          = require 'path'
osenv         = require 'osenv'
mkdirp        = require 'mkdirp'
fs            = require 'fs'

module.exports = ->
  p = path.join(osenv.home(), '.config/roots/templates')
  if not fs.existsSync(p) then mkdirp.sync(p)
  new Sprout(p)