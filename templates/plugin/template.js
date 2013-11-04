// roots plugin template
// ---------------------

// If you are using external dependencies, you must use `module.require()`, as this file
// will be executed in roots' environment.

// Required for compiler to run.
// @param {string} file_type - File extension compiled by this plugin
// @param {string} target - File extension output from this plugin
exports.settings = {
  file_type: 'xxx',
  target: 'css'
}

// Compiles a single file
// @param {object} file - An object containing lots of information about the file
// @param {function} callback - Execute when finished. Takes error and output.
exports.compile = function(file, options, callback){
  var compiled_contents, error = false;

  // This is a good way to find out what's in the file object ; )
  console.log(file);

  // This compiler just converts everything to uppercase
  // Yours probably actually does something useful.
  try {
    compiled_contents = file.contents.toUpperCase();
  } catch(err){
    error = err
  }

  // Hit the callback only when the compile is finished. If you are compiling
  // html and want it to work with roots' layout system, you must return a 
  // function here rather than a string.
  callback(error, compiled_contents);
}
