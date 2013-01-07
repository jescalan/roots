// roots plugin template
// ---------------------

// if you are using external dependencies, you must use `module.require()`, as this file
// will be executed in roots' environment.

// you must exports a settings object in order for the compiler to be used
exports.settings = {
  file_type: 'xxx',
  target: 'css'
}

// the compile method is passed a list of files of the file type specified in the above
// settings object, a helper class, and a callback. the callback must be called only
// once all files have been compiled
exports.compile = function(file, Helper, callback){
  var error = false;

  // the helper has a ton of useful methods for managing the file paths, contents,
  // and writing the file to the right place. pass the constructor a file.
  // full helper documentation is available at http://roots.cx//plugins
  var helper = new Helper(file);

  // do your compiler thing here. if this is an async function, it is your responsability
  // to manage it and hit the callback at the right time. this example is assumed to be sync.
  try {
    var compiled_contents = helper.file_contents;
  } catch (err) {
    error = err;
  }

  // helper.write will write a string to the right file in /public, compressing it when
  // necessary. I prefer not to write files when there's an error.
  !error && helper.write(compiled_contents);
  
  // when all files are finished compiling, hit the callback. if you want roots to
  // handle your errors, pass a string with the error (or false if no errors).
  callback(error);
}