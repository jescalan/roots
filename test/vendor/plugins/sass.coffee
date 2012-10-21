
# sass compiler plugin
# --------------------

# sass ruby gem must be installed to use this compiler

exports.settings =
  file_type: 'sass'
  target: 'css'

exports.compile = (files, options, Helper, cb) ->
  error = false
  counter = 0

  files && files.forEach (file) ->
    console.log 'sass file detected'
    helper = new Helper(file)
    require('child_process').exec "sass #{helper.file_path}", (err, compiled_sass) ->
      error = err if err
      console.log compiled_sass
      helper.write(compiled_sass) unless error
      
      counter++
      cb(error) if counter == files.length