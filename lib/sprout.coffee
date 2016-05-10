Sprout        = require 'sprout'
path          = require 'path'
osenv         = require 'osenv'
mkdirp        = require 'mkdirp'
fs            = require 'fs'
global_config = require('./global_config')

module.exports = ->
  tpl_path = path.join(global_config.dir, 'templates')
  if not fs.existsSync(tpl_path) then mkdirp.sync(tpl_path)
  new Sprout(tpl_path)
