# test compiler
# -------------

exports.settings =
  file_type: 'blarg'
  target: 'liquid'

exports.compile = (file, options, callback) ->
  error = false
  compiled_contents = null

  try
    compiled_contents = file.contents.replace(/hello/, 'blarg')
  catch err
    error = err

  callback(error, compiled_contents)
