fs      = require 'fs'
ncp     = require('ncp').ncp
run     = require('child_process').exec
path    = require 'path'
rimraf  = require 'rimraf'
assert  = require 'assert'
dir     = 'watch-scratch'

run_in_dir_async = (dir, cmd, cb) ->
  run "cd \"#{dir}\"; #{path.join(path.relative(dir, __dirname), '../bin/roots')} #{cmd}"
  cb()

describe 'watch', ->
  beforeEach (done) ->
    ncp path.join(__dirname, 'basic'), path.join(__dirname, dir), ->
      done()

  afterEach (done) ->
    rimraf path.join(__dirname, dir), ->
      done()

  it 'should reload on content change', (done) ->
    run_in_dir_async path.join(__dirname, dir), 'watch', ->
      # this is so ghetto
      # if i was in a neighborood this ghetto
      # they would steal my socks
      this.setTimeout =>
        fs.appendFileSync path.join(__dirname, dir, 'views/index.jade'), 'h2 hi!'
        this.setTimeout ->
          content = fs.readFileSync path.join(__dirname, dir, 'public/index.html'), 'utf8'
          assert.equal true, !!~content.indexOf("<h2>hi!</h2>"), "contains content"
          done()
        , 1000
      , 2000