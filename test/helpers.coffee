path = require 'path'
fs = require 'fs'

module.exports = (should) ->

  should.exist = (base, files) ->
    if !Array.isArray(files) then files = [files]
    for file in files
      fpath = path.join(base, file)
      fs.existsSync(fpath).should.equal(true, "expected #{fpath} to exist")

  should.not_exist = (base, files) ->
    if !Array.isArray(files) then files = [files]
    for file in files
      fpath = path.join(base, file)
      fs.existsSync(fpath).should.equal(false, "expected #{fpath} not to exist")

  should.contain_content = (base, file, matcher) ->
    fpath = path.join(base, file)
    contents = fs.readFileSync(fpath, 'utf8')
    contents.should.match(matcher, "expected #{fpath} to contain #{matcher}")

  should.not_contain_content = (base, file, matcher) ->
    fpath = path.join(base, file)
    contents = fs.readFileSync(fpath, 'utf8')
    contents.should.not.match(matcher, "expected #{fpath} not to contain #{matcher}")

  should.match_dir = (dir, original) ->
    dir_src = fs.readdirSync(dir).filter((o) -> return !o.match /^\./ )
    orig_src = fs.readdirSync(original).filter((o) -> return !o.match /^\./ )
    dir_src.should.eql(orig_src, "expected #{dir} to match #{original}")

  should.match_file = (base, file, expected) ->
    file_contents = fs.readFileSync(path.join(base, file), 'utf8')
    expected_contents = fs.readFileSync(path.join(base, expected), 'utf8')
    file_contents.should.equal(expected_contents, "expected #{file} contents to match #{expected}")
