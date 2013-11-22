exports.settings =
  file_type: 'xxx'
  target: 'css'

exports.compile = (file, options, cb) ->
  cb(error, file.contents)
