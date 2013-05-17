exports.settings =
  file_type: 'coil'
  target: 'coil'

exports.compile = (file, callback) ->
  error = false
  compiled_contents = null

  try
    compiled_contents = file.contents.replace('world', 'coil')
  catch err
    error = err

  callback(error, compiled_contents)