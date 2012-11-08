# roots plugin template
# ---------------------

# this file will be processed by node.js
# if you are using external dependencies, they must be installed in your project directly.
# this file will be executed in roots' environment.

# you must exports a settings object in order for the compiler to be used
exports.settings =
  file_type: 'styl'
  target: 'css'

# the compile method is passed a list of files of the file type specified in the above
# settings object, a helper class, and a callback. the callback must be called only
# once all files have been compiled
exports.compile = (files, Helper, cb) ->
  error = false

  # loop through all of the files
  files.forEach (file) ->

    # the helper has a ton of useful methods for managing the file paths, contents,
    # and writing the file to the right place. pass the constructor a file.
    helper = new Helper(file)

    # do your compiler thing here. if this is an async function, it is your responsability
    # to manage it and hit the callback at the right time. this example is assumed to be sync.
    try
      compiled_contents = someCompiler.compile(helper.file_contents)
    catch (err)
      error = err

    # helper.write will write a string to the right file in /public, compressing it when necessary
    # I prefer not to write files when there's an error.
    helper.write(compiled_contents) unless error
  
  # when all files are finished compiling, hit the callback, passing either
  # false or an error message as a string
  cb(error)