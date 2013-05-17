var Snockets = require('snockets');

exports.settings = {
  file_type: 'coffee',
  target: 'js'
};

exports.compile = function(file, cb){
  var error, compiled;

  // custom compiler for bare coffeescript
  var snockets = new Snockets();
  if (global.options.coffeescript_bare) {
    Snockets.compilers.coffee.compileSync = function(sourcePath, source) {
      return require('coffee-script').compile(source, { filename: sourcePath, bare: true });
    };
  }

  try {
    compiled = snockets.getConcatenation(file.path, { async: false });
  } catch (err) {
    error = err;
  }
    
  cb(error, compiled);
};
