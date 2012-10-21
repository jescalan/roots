
# sass compiler plugin
# --------------------

# sass ruby gem must be installed to use this compiler

exports.settings =
  file_type: 'sass'
  target: 'css'

exports.compile = (files, options, helper, cb) ->
  error = false
  files && files.forEach (file) ->
    helper = new helper(file)
    require('child_process').exec "sass #{helper.file_path}", (err, out, stderr) ->
      error = err if err
      helper.write(out)
      cb(error)