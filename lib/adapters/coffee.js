var Snockets = require('snockets');

exports.settings = { file_type: 'coffee', target: 'js' }

exports.compile = function(files, Helper, cb){
  var error;

  // custom compiler for bare coffeescript
  var snockets = new Snockets();
  if (global.options.coffeescript_bare) {
    Snockets.compilers.coffee.compileSync = function(sourcePath, source) {
      return require('coffee-script').compile(source, { filename: sourcePath, bare: true });
    }
  }

  files.forEach(function(file){

    try {
      var helper = new Helper(file)
      var compiled_js = snockets.getConcatenation(helper.file_path, { async: false });
      helper.write(compiled_js)
    } catch (err) {
      error = err;
    }
    
  });
  cb(error);
}