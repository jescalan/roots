require('coffee-script');
var CompileHelper = require('./compile-helper.coffee');

exports.copy_files = function(files, cb){
  typeof files !== 'undefined' && files.forEach(function(file){

    var helper = new CompileHelper(file)
    helper.write(helper.file_contents)

  });
  cb();
}