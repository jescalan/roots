# test compiler
# -------------

exports.settings =
  file_type: 'blarg'
  target: ''

exports.compile = (file, callback) ->
  error = false
  compiled_contents = null

  try
    compiled_contents = file.contents.replace(/hello/, 'blarg')
  catch err
    error = err

  callback(error, compiled_contents)
