# --------------------
# sass compiler plugin
# --------------------

# sass ruby gem must be installed to use this compiler

test = module.require('./test')

exports.settings =
  file_type: 'sass'
  target: 'css'

exports.compile = (file, cb) ->

  error = false
  compiled = null

  require('child_process').exec "sass #{file.path}", (err, compiled_sass) ->
    error = err if err
    compiled = compiled_sass
    
    cb(error, compiled)