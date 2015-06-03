Sprout        = require 'sprout'
path          = require 'path'
osenv         = require 'osenv'
os            = require 'os'
crypto        = require 'crypto'
mkdirp        = require 'mkdirp'
fs            = require 'fs'

module.exports = (p = sprout_user_path()) ->
  if p == sprout_user_path() and not fs.existsSync(p) then mkdirp.sync(p)
  new Sprout(p)

sprout_user_path = ->
  user = (osenv.user() || generate_fake_user()).replace(/\\/g, '-')
  tmp = path.join((if os.tmpdir then os.tmpdir() else os.tmpDir()), user)
  path.join((osenv.home() || tmp), '.config', 'roots', 'templates')

generate_fake_user = ->
  uid = [process.pid, Date.now(), Math.floor(Math.random()*10000000)].join('-')
  crypto.createHash('md5')
    .update(uid)
    .digest('hex')
