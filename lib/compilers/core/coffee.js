require('coffee-script');
var CompileHelper = require('../compile-helper.coffee'),
    Snockets = require('snockets');

exports.settings = { file_type: 'coffee', target: 'js' }

exports.compile = function(files, cb){
  var error;
  typeof files !== 'undefined' && files.forEach(function(file){

    // this uses snockets to compile, which makes the require command
    // available within coffeescript files. dope!

    try {
      var helper = new CompileHelper(file)
      var snockets = new Snockets();
      var compiled_js = snockets.getConcatenation(helper.file_path, { async: false });
      helper.write( compiled_js )
    } catch (err) {
      error = err;
    }
    
  });
  cb(error);
}