require('coffee-script');
var CompileHelper = require('./compile-helper.coffee');

exports.copy_files = function(extension, files, options, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    var helper = new CompileHelper(file, options, extension)
    helper.write( helper.file_contents )

  });
  cb();
}