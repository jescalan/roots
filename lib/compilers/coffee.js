require('coffee-script');
var CompileHelper = require('compile-helper.coffee'),
    Snockets = require('snockets');

exports.compile = function(options, files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    // this uses snockets to compile, which makes the require command
    // available within coffeescript files. dope!

    var helper = new CompileHelper(file, options, 'coffee')
    var snockets = new Snockets();
    var compiled_js = snockets.getConcatenation(helper.file_path, { async: false });
    helper.write( compiled_js )
    
  });
  cb();
}